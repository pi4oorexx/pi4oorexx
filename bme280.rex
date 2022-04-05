
/*--------------------------------------------------------------------*/
/*						bme280.rex                                    */
/*                                                                    */
/* this program demonstrates the control of a BME280 temperature,     */
/* air pressure and humidity sensor via I²C bus                       */
/*                                                                    */
/*--------------------------------------------------------------------*/
/*https://github.com/siketyan/TempRa/blob/master/src/main/java/io/github/siketyan/monitor/util/BME280.java*/




------------------------------------------------------------------------
------------------------------------------------------------------------
-- Example

call setupBme

say getTemp()
say getPressure()
say getHumidity()

exit 0

------------------------------------------------------------------------
------------------------------------------------------------------------

---------------
---------------
/*returns temp*/
::routine getTemp public
temp = calcValues()
return temp~temp
---------------
---------------
/*return Pressure*/
::routine getPressure public
p = calcValues()
return p~pressure
---------------
---------------
/*return humidity*/
::routine getHumidity public
h = calcValues()
return h~humidity
---------------
---------------
/*read and calcutes the values*/
::routine calcValues
-- read compesations parameter
data = bsf.createJavaArray("byte.class",24)
.device~read(136,data,0,24)

-- convert Data     Datasheet Table 16
-- temperature coeffocients

dig_T1 = (0xff(data[1])) + ((0xff(data[2]))*256)

dig_T2 = (0xff(data[3])) + ((0xff(data[4]))*256)
if dig_T2 > 32767 then dig_T2 = dig_T2 - 65536

dig_T3 = (0xff(data[5])) + ((0xff(data[6]))*256)
if dig_T3 > 32767 then dig_T3 = dig_T3 - 65536

-- pressure coefficients

dig_P1 = (0xff(data[7])) + ((0xff(data[8]))*256)

dig_P2 = (0xff(data[9])) + ((0xff(data[10]))*256)
if dig_P2 > 32767 then dig_P2 = dig_P2 - 65536

dig_P3 = (0xff(data[11])) + ((0xff(data[12]))*256)
if dig_P3 > 32767 then dig_P3 = dig_P3 - 65536

dig_P4 = (0xff(data[13])) + ((0xff(data[14]))*256)
if dig_P4 > 32767 then dig_P4 = dig_P4 - 65536

dig_P5 = (0xff(data[15])) + ((0xff(data[16]))*256)
if dig_P5 > 32767 then dig_P5 = dig_P5 - 65536

dig_P6 = (0xff(data[17])) + ((0xff(data[18]))*256)
if dig_P6 > 32767 then dig_P6 = dig_P6 - 65536

dig_P7 = (0xff(data[19])) + ((0xff(data[20]))*256)
if dig_P7 > 32767 then dig_P7 = dig_P7 - 65536

dig_P8 = (0xff(data[21])) + ((0xff(data[22]))*256)
if dig_P8 > 32767 then dig_P8 = dig_P8 - 65536

dig_P9 = (0xff(data[23])) + ((0xff(data[24]))*256)
if dig_P9 > 32767 then dig_P9 = dig_P9 - 65536

-- Read dig_H1 from 0xA1 -> 161

data_H1 = bsf.createJavaArray("byte.class",1)
.device~read(161,data_H1,0,1)

dig_H1 = (0xff(data_H1[1]))

-- Read 7 Bytes from 0xE1  -> 225

data2 = bsf.createJavaArray("byte.class",7)
.device~read(225,data2,0,7)

-- humidity coefficients

dig_H2 = (0xff(data2[1]) + (data2[2]*256))
if dig_H2 > 32767 then dig_H2 = dig_H2 - 65536

dig_H3 = 0xff(data2[3])

dig_H4 = ((0xff(data2[4])*16) +(0xf(data2[5])))				--- 0xff 0xf
if dig_H4 > 32767 then dig_H4 = dig_H4 - 65536

dig_H5 = ((0xff(data2[5])/16) +(0xff(data2[6])*16))				--- 0xff 0xff
if dig_H5 > 32767 then dig_H5 = dig_H5 - 65536

dig_H6 = (0xff(data2[7]))
if dig_H6 > 127 then dig_H6 = dig_H6 - 256

--select control humidity register

com1 = bsf.createJavaArray("byte.class",1)
com1~put(box("byte.class",1),1)	-- 0x01 = 1
.device~write(242,com1)			--0xF2 = 242

--select control measurement register

com2 = bsf.createJavaArray("byte.class",1)
com2~put(box("byte.class",39),1)	--0x27 = 39
.device~write(244,com2)			--0xF4 = 244

--select config register

com3 = bsf.createJavaArray("byte.class",1)
com3~put(box("byte.class",-96),1)			--- 0xA0 -> -96 (byte)  --->java Byte
.device~write(242,com3)			--0xF5 = 245


call syssleep 1				-- pause

--read measured data from 0xF7 -> 247    8 Byte

meas = bsf.createJavaArray("byte.class",8)
.device~read(247,meas,0,8)

-- convert pressure and temp

adc_p = ((0xff(meas[1])*65536) + (0xff(meas[2])*256) + (0xff(meas[3])))/16
adc_t = ((0xff(meas[4])*65536) + (0xff(meas[5])*256) + (0xff(meas[6])))/16

-- convert humidity data

adc_h = (0xff(meas[7])*256)+(0xff(meas[8]))

--Temp offset calculation

var1 = ((adc_t / 16384) - (dig_T1 / 1024)) * dig_T2
var2 = (((adc_t / 131072) -(dig_T1 / 8192)) * ((adc_t / 131072) - (dig_T1 / 8192)))	*  dig_T3	---			131072 = 2^16

t_fine = var1 + var2
temp = (t_fine) / 5120

-- pressure offset calculation

var3 = (t_fine / 2) - 64000
var4 = var3 * var3 * dig_P6 / 32768
var4 = var4 * var3 * dig_P5 * 2
var4 = (var4 / 4) + (dig_P4 * 65536)
var3 = (dig_P3 * var3 * var3 / 524288 + dig_P2 * var3) / 524288
var3 = (1 + var3 / 32768) * dig_P1

p = 1048576 - adc_p
p = (p-(var4/4096))*6250 / var3
var3 = dig_P9 * p * p / 2147483648
var4 = p * dig_P8 / 32768

pressure = (p+ (var3 + var4 + dig_P7) / 16 ) / 100

-- humidity offset calculation

var_H = t_fine - 76800
var_H = (adc_h - (dig_H4 * 64 + dig_H5/16384 * var_H))* (dig_H2 / 65536 * ( 1 + dig_H6 / 67108864 * var_H * (1 + dig_H3/67108864 * var_H)))
humidity = var_H * ( 1 - dig_H1 * var_H / 524288)

DataColl = .directory~new
DataColl~~temp = temp
DataColl~~pressure = pressure
DataColl~~humidity = humidity

return DataColl
---------------
---------------
/*load all required classes and make the i2c connection available locally*/
::routine setupBme public
pkgLocal=.context~package~local  -- get package local directory
device = bsf.loadClass("com.pi4j.io.i2c.I2CDevice")
i2cbus = bsf.loadClass("com.pi4j.io.i2c.I2CBus")
bus = bsf.loadClass("com.pi4j.io.i2c.I2CFactory")~getInstance(i2cbus~BUS_1)
pkgLocal~device = bus~getDevice(119) --0x77 =    hex -> int
return
---------------
---------------
/* the 0xff routine checks if the number is negative and if it
is the value is made positive with +256
 --  v &  0xff --  in Java */
::routine 0xFF
use arg v

if v < 0 then
	do
		v= v+256
		return v
	end
else return v

----------------
----------------
/* the 0xf routine returns a value between 0-15.
v &  0xf   in Java
*/

::routine 0xF
use arg v
return 0xff(v)//16
----------------
----------------
::requires bsf.cls
