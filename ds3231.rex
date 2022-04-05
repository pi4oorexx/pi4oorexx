/*--------------------------------------------------------------------*/
/*                                                                    */
/*                      DS3231 Real Time Clock                        */
/*                 with Pi4J and BSF4ooRexx support                   */
/*                                                                    */
/* the DS3231 real time clock provides the Raspberry Pi with an       */
/* exact time, even if there is no internet connection.               */
/* The I²C bus is used for control. The bus is accessed via Pi4J      */
/* and BSF4ooRexx. There are four routines. One each to set the time  */
/* and date and to read the time and date.                            */
/*                                                                    */
/*--------------------------------------------------------------------*/

--example
--Call setup
call setupDs3231
--set Time and Date
call setTime 23 ,59 ,44   -- hh mm ss
call setDate 22,12,31     -- yy momo dd


do forever
say getTime()
say getDate()
call syssleep 1
end

exit
::requires BSF.CLS  -- get Java Support
---------
---------
/*routine for reading the time*/
::routine getTime public
read = bsf.CreateJavaArray("byte.class",1)
.device~read(0,read,0,1)
s= read[1]~d2x
.device~read(1,read,0,1)
m= read[1]~d2x
.device~read(2,read,0,1)
h= read[1]~d2x
time = h":"m":"s
return time
------
------
/*routine for reading the date*/
::routine getDate public
read = bsf.CreateJavaArray("byte.class",1)
.device~read(4,read,0,1)
d= read[1]~d2x
.device~read(5,read,0,1)
mo= read[1]~d2x
.device~read(6,read,0,1)
y= read[1]~d2x
date = y"."mo"."d
return date

------
------
/*routine to set the desired time */
::routine setTime public
use arg hh,mm,ss
.device~write(0,BSFRawBytes(ss~x2c))
.device~write(1,BSFRawBytes(mm~x2c))
.device~write(2,BSFRawBytes(hh~x2c))
return

------
------
/*routine to set the desired date */

::routine setDate public
use arg yy, momo,dd
.device~write(4,BSFRawBytes(dd~x2c))
.device~write(5,BSFRawBytes(momo~x2c))
.device~write(6,BSFRawBytes(yy~x2c))
return
------
------
/* get access to all required classes */
::routine setupDs3231 public
pkgLocal=.context~package~local  -- get package local directory
device = bsf.loadClass("com.pi4j.io.i2c.I2CDevice")
i2cbus = bsf.loadClass("com.pi4j.io.i2c.I2CBus")
bus = bsf.loadClass("com.pi4j.io.i2c.I2CFactory")~getInstance(i2cbus~BUS_1)
pkgLocal~device = bus~getDevice(104)


