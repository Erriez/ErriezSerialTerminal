rem Install Python27 platformio
rem C:\Python27\Scripts\pip.exe install -U platformio

rem Set Python path
set PATH=%PATH%;C:\Python27
set PATH=%PATH%;C:\Python27\Scripts

rem Update library
rem git fetch
rem git pull

rem Build example(s)
platformio ci --lib=".." --board uno --board micro --board d1_mini --board nanoatmega328 --board pro16MHzatmega328 --board pro8MHzatmega328 --board leonardo --board megaatmega2560 --board due --board d1_mini --board nodemcuv2 --board lolin_d32 ../examples/SerialTerminal/SerialTerminal.ino

@pause