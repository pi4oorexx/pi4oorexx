-- RFIDAttendace.rex
--program description at the end of the source code
-----------------------------------------------------------------
call setup
call syssleep 0.2
.screen~clear
call syssleep 0.2
say "start"
do forever
.screen~display_string_pos("TIME"(),1,3)

    if .pinCome~getState~toString =="HIGH" then call readwrite "come"   -- come button pressed
	if .pinGo~getState~toString =="HIGH" then call readwrite "go"       -- go button pressed
    call syssleep(0.2)
end

exit

::requires BSF.CLS -- get Java Support
-----------
-----------
::routine readwrite
use arg cg

nocard = 0  --so that display is not constantly updated when no card is present

	    do i=1 to 10	-- 10 reading attempts
            carddata= .rc522client~readCardData
		    call syssleep(0.1)
		    readok=0
		    if carddata == .nil then 	do

					say "no card yet"
					if nocard ==0 then do
    					.screen~clear
						.screen~display_string_pos("Hold card",1,0)
						.screen~display_string_pos("to reader",2,0)
						nocard = 1
					end
			end
		    else do
				tagID = carddata~getTagIdAsString
				say "card detected" tagID
				emp = .stream~new("emp.dat")
				emp~open("read")

		        do while emp~lines<> 0
                    data = emp~linein
				    parse var data tag "," name "," perso
                    if tag = tagID then do
				       --say tagid passt
				       file =.stream~new("attendance.csv")
				       file~open("write")
				       if cg = "come" then do
				       file~lineout(date() ", "Time() "," name "," COME)
				        say come
				            .screen~clear
                            .screen~display_string_pos("card detected" ,1,0)
                            .screen~display_string_pos(("Hi" name) ,2,0)
				       end
				       else do
				       file~lineout(date() ", "Time() "," name "," GO)
				           say  go
				            .screen~clear
                            .screen~display_string_pos("card detected" ,1,0)
                            .screen~display_string_pos("Bye" name,2,0)
				       end
				       file~close
				       call beep 1
                       call syssleep (2)   ---> damit man Ausgabe von "Hallo" lesen kann
                       	i=10  --> damit abfrage beendet wird
                       	readOK = 1
				    end
                end
			end

		call syssleep(0.2)

		if (i==10 & readok == 0)  then do
			.screen~clear
			.screen~display_string_pos("no card",1,0)
			.screen~display_string_pos("detected!!!",2,0)
            call syssleep(1)
            call beep 3
		end

	end
	.screen~clear

return

::routine beep
use arg n

do i = 1 to n
.pinBuzzer~low
call Syssleep(0.05)
.pinBuzzer~high
call Syssleep(0.05)
end
return
-----------
-----------

::routine setup
pkgLocal=.context~package~local  -- get package local directory
--- initialzie MFRC522
rc522clientimpl = bsf.loadClass("at.pi4oorexx.mfrc522.rc522.RC522ClientImpl")
card = bsf.loadClass("at.pi4oorexx.mfrc522.model.card.Card")
pkgLocal~rc522client = rc522clientimpl~createInstance
--- initialize Button and Buzzer

gpio = bsf.loadClass("com.pi4j.io.gpio.GpioFactory")~getInstance
RaspiPin = bsf.loadClass("com.pi4j.io.gpio.RaspiPin")
PinPullDown = bsf.loadClass("com.pi4j.io.gpio.PinPullResistance")~PULL_DOWN
pkgLocal~pinCome = gpio~provisionDigitalInputPin(RaspiPin~GPIO_05,PinPullDown)
pkgLocal~pinGo = gpio~provisionDigitalInputPin(RaspiPin~GPIO_24,PinPullDown)
pinstate = bsf.loadClass("com.pi4j.io.gpio.PinState")
pkgLocal~pinBuzzer = gpio~provisionDigitalOutputPin(RaspiPin~GPIO_01,pinstate~high)

--- initialize LC- Display

device = bsf.loadClass("com.pi4j.io.i2c.I2CDevice")
lcd = bsf.import("at.pi4oorexx.lcd.I2CLCD")
i2cbus = bsf.loadClass("com.pi4j.io.i2c.I2CBus")
bus = bsf.loadClass("com.pi4j.io.i2c.I2CFactory")~getInstance(i2cbus~BUS_1)
device = bus~getDevice(box('int',39)) --0x27 = 39   hex -> int
pkgLocal~screen =lcd~new(device)
return
-----------
-----------


/*
This program provides a simple RFID attendance system.
With this it is possible to log the attendance of employees.
For this, a data with employee data is needed where their card ID, name, etc. is entered.
*/



