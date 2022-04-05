/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 PCF8591 8-bit A/D converter                        */
/*                        with i2cget                                 */
/*                                                                    */
/* The PCF 8591 is an analog to digital converter with a resolution   */
/* of 8 bit. The converter returns values between 0-255. The          */
/* converter has a total of four analog inputs which are numbered     */
/* from A0 to A3.                                                     */
/* There is only one routine to read out the desired analog input.    */
/* It is important to mention that two queries have to be sent to the */
/* chip, because the chip returns the actual value only at the second */
/* query. at the first query the last measured value will be          */
/* returned.                                                          */
/*                                                                    */
/*--------------------------------------------------------------------*/

--example
say getAnalogInput(2)
exit


::routine getAnalogInput public
use arg input

if input = 0 then addr = "0x40"
else if input = 1 then addr = "0x41"
else if input = 2 then addr = "0x42"
else if input = 3 then addr = "0x43"
else say "falsche eingabe"

value = .array~new
address system "i2cget -y 1 0x48 " addr with output append using(value)  -- dummy query
address system "i2cget -y 1 0x48 " addr with output append using(value)

return x2d(substr(value[2] ,3))  -- 0xf5 -> f5
