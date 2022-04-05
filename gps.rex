/*--------------------------------------------------------------------*/
/*						gps.rex                                       */
/*                                                                    */
/* This program uses a Neo-6M GPS sensor to receive the location data.*/
/* The data is received via the serial port of the Raspberry Pi.      */
/* The connection to the serial interface is established with         */
/* BSF4ooRexx and the pi4j library                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/


/*load required classes from Java*/

serial = bsf.loadClass("com.pi4j.io.serial.SerialFactory")~createInstance
port = bsf.loadClass("com.pi4j.io.serial.SerialPort")
baud = bsf.loadClass("com.pi4j.io.serial.Baud")
dataBits = bsf.loadClass("com.pi4j.io.serial.DataBits")
parity= bsf.loadClass("com.pi4j.io.serial.Parity")
stopBits= bsf.loadClass("com.pi4j.io.serial.StopBits")
flowControl= bsf.loadClass("com.pi4j.io.serial.FlowControl")
config = .bsf~new("com.pi4j.io.serial.SerialConfig")

/* Initialize the serial port */

po=port~getDefaultPort     --ttyS0
b=baud~_9600
d= dataBits~_8
pa = parity~NONE
st=stopBits~_1
f=flowControl~NONE
config~device(po)~baud(b)~dataBits(d)~parity(pa)~stopBits(st)~flowControl(f)
serial~open(config)

------------------------------------------------------------------------
------------------------------------------------------------------------
/* Main Program*/

/*read raw data from GPS-modul*/
GpsData = readData(serial)

/*If no data is received more than ten times, the program is aborted
and an error message is displayed.*/
count = 1
do while (validateData(Gpsdata) = .False)
    say "no valid Data Receiveid Nr." count
	if count >= 10 then do
		say "no valid data received- check antenna"
		exit
	end
	call syssleep 1
	GpsData = readData(serial)
	--say GpsData								--debug
	count = count + 1
end

/* valid values were received and were checked by checksum*/

preparedData = prepareData(GpsData)

say preparedData~date
say preparedData~time
say preparedData~latitude
say preparedData~longitude

/*close the serial port*/
serial~close
exit 0

----------------------------------------------------------------------
----------------------------------------------------------------------

/*Routines*/

---------------
---------------

/* Putting data into a readable format
https://docs.novatel.com/OEM7/Content/Logs/GPRMC.htm

Time
Date
Latitude
Longitude

*/

::routine prepareData
parse arg gps
DataColl = .directory~new
parse var gps utc +6 13 lat +10 24 latDir +1 26 lon +11 38 lonDir +1 47 dat +6 .
--prepare Time
time =substr(utc,1,2) || ":"|| substr(utc,3,2) || ":" || substr(utc,5,2) "UTC"
DataColl ~~time = time
--prepare latitude
latitude = substr(lat,1,2) || "." || substr(lat,3,2) || substr(lat,6,5) || latDir
DataColl ~~latitude = latitude
--prepare longitude
longitude = substr(lon,1,3) || "." ||  substr(lon,4,2) || substr(lon,7,5) || lonDir
DataColl ~~longitude = longitude
--prepare Date
date = substr(dat,1,2) || "." || substr(dat,3,2) || "." || substr(dat,5,2)			-- dd/mm/yy
DataColl ~~date =date
return dataColl

---------------
---------------


/* read data of the GPS module into an array.
The module (NEO-6M) has an update rate of 1Hz.*/

::routine readData
use arg serial
datastring = ""
do i=1 to 300
	a=serial~getInputStream
	datastring = datastring a~read~d2c
end

datastring = space(datastring,0)
/*Cut out desired part (GPRMC) from the string*/
parse var datastring useless "$GPRMC," firstcut			-- everything before incl. "$GPRMC," will be truncated
parse var firstcut receivedDataRaw "$GPVTG" .			-- everything before incl. "$GPVTG," will be truncated
parse var receivedDataRaw receivedData +59				-- deletes <cr> <lf>
return receivedData



---------------
---------------

/*checks if the received data is complete and if it was
  received correctly. If the data is correct a .TRUE will
  be returned otherwise a .FALSE */

::routine validateData
parse arg checkData
/* check if data are available */
if checkData~length > 0 then do
   /*read checksum from string */
	parse var checkData data "*" checksum

	/*Since "GPRMC," also belongs to the calculation of the checksum,
	  but this value has already been cut out to facilitate
	  the search process, the value precalculated value is
	  inserted into the variable a
	  the precalculated value results in a = "g" */
	a="g"
    do i=1 to data~length
		erg = bitxor(a,data[i])
		a=erg
	end
	checksum_calc = c2x(a)
	/*check if the received checksum is equal to the calculated one*/
	if checksum = checksum_calc then do
		return .True
	end
	else do
		return .False
	end
end
else do
	return .False
end

::requires BSF.CLS




/*
Useful links

NMEA:

https://gpsd.gitlab.io/gpsd/NMEA.html
https://gpsd.gitlab.io/gpsd/NMEA.html#_rmc_recommended_minimum_navigation_information

calculate Checksum:

https://stackoverflow.com/questions/32076761/nmea-checksum-calculation-calculation

*/
