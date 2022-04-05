/*--------------------------------------------------------------------*/
/*                                                                    */
/*                   BH1750 Ambient Light Sensor                      */
/*                 with pi4oorexx support                             */
/*                                                                    */
/* The BH1750 Ambient Light Sensor is able to measure the             */
/* illuminance in the unit lux. There are two routines.               */
/* With "~getOptical" the measured values of the sensor can be        */
/* read out. The help function "~help" is also available.             */
/*--------------------------------------------------------------------*/

bh = bsf.loadClass("at.pi4oorexx.bh1750.BH1750")~getInstance(1,35)  -- bus nr and address 0x23 -> int 35
say bh~getOptical  -- get Data
bh~help   -- get Help from pi4oorexx
exit
::requires BSF.CLS --get Java Support
