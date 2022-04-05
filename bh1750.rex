/*--------------------------------------------------------------------*/
/*                                                                    */
/*                   BH1750 Ambient Light Sensor                      */
/*                 with Pi4J and BSF4ooRexx support                   */
/*                                                                    */
/* The BH1750 Ambient Light Sensor is able to measure the             */
/* illuminance in the unit lux. There are two routines.               */
/* The routine "setup_bh1750" is necessary for loading all            */
/* required classes and making them available locally.                */
/* The routine "read_bh1750" returns the measured value of the sensor.*/
/*                                                                    */
/*--------------------------------------------------------------------*/

--example
call setupBh1750
say readBh1750()
exit
::requires BSF.CLS  -- get Java support

------
------
/* get access to all required classes */
::routine setupBh1750 public
pkgLocal=.context~package~local  -- get package local directory
device = bsf.loadClass("com.pi4j.io.i2c.I2CDevice")
i2cbus = bsf.loadClass("com.pi4j.io.i2c.I2CBus")
bus = bsf.loadClass("com.pi4j.io.i2c.I2CFactory")~getInstance(i2cbus~BUS_1)
pkgLocal~device = bus~getDevice(35)
return

-------
-------
/*Perform measurement*/
::routine readBh1750 public
--values from the data sheet
power = 1 --  Power on
mode = 20 -- One Time H-Res Mode 1lx Resolution --> Datasheet

/* Activate sensor and select mode */
.device~write(BsfRawBytes(power~x2c))
call syssleep 0.05
.device~write(BsfRawBytes(mode~x2c))
call syssleep 0.5

/* Read out measured data */
read = bsf.CreateJavaArray("byte.class",2)
.device~read(read,0,2)

/* Convert measured values according to data sheet */
msb = 0xff(read[1]) * 256
lsb= 0xff(read[2])
return (msb+lsb)/1.2

-------
-------
/*Converts the measured byte from a signed byte(-128 -> 127) to an unsigned byte(0 -> 255)*/

::routine 0xff
     use arg v
     if v < 0 then return v+256
     return v
------
------
