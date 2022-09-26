
#include <WaspSensorCities_PRO.h>
#include <Wasp4G.h>
#include <WaspPM.h>
///////////////////////////////////////
// APN settings
///////////////////////////////////////
char apn[] = "almadar.net";
char login[] = "";
char password[] = "";
///////////////////////////////////////
// SERVER settings
///////////////////////////////////////
char host[] = "your host";
uint16_t port = 80;
char resource[] = "";
///////////////////////////////////////
// Sensors variables
int error;
bmeCitiesSensor bme(SOCKET_E);
Gas gas_sensorCO(SOCKET_B);
Gas gas_sensorCO2(SOCKET_C);
Gas gas_sensorNO(SOCKET_F);
Gas gas_sensorNO2(SOCKET_A);
int status;
int measure;
void setup()
{
  USB.ON();
  USB.println(F("Start program"));
  //////////////////////////////////////////////////
  // 1. sets operator parameters
  //////////////////////////////////////////////////
  _4G.set_APN(apn, login, password);
  //////////////////////////////////////////////////
  // 2. Show APN settings via USB port
  //////////////////////////////////////////////////
  _4G.show_APN();
}
void loop()
{
float NO;  // Stores the concentration level in ppm
float NO2;  // Stores the concentration level in ppm
float CO;  // Stores the concentration level in ppm
float CO2;  // Stores the concentration level in ppm
float temperature;  // Stores the temperature in ºC
float humidity;   // Stores the realitve humidity in %RH
float pressure;   // Stores the pressure in Pa
float PM1;
float PM25;
float PM10;
  gas_sensorCO.OFF();
  gas_sensorCO2.OFF();
  gas_sensorNO.OFF();
  gas_sensorNO2.OFF();
  bme.ON();
  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();
  bme.OFF();
  gas_sensorCO.ON();
  gas_sensorCO2.ON();
  gas_sensorNO.ON();
  gas_sensorNO2.ON();
  CO = gas_sensorCO.getConc(temperature);
  CO2 = gas_sensorCO2.getConc(temperature);
  NO = gas_sensorNO.getConc(temperature);
  NO2 = gas_sensorNO2.getConc(temperature);
  PM.ON();
// Power the fan and the laser and perform a measure of 5 seconds
  PM.getPM(5000, 5000);
  PM1=PM._PM1;
  PM25=PM._PM2_5;
  PM10=PM._PM10;
  PM.OFF();
  char temp[4]="";
  char data[200]="deviceId=37801CE819623C0E&no=";

  Utils.float2String (NO, temp, 3);
  strcat(data,temp);
  strcat(data,"&no2=");

  Utils.float2String (NO2, temp, 3);
  strcat(data,temp);
  strcat(data,"&co=");
  USB.println("5");
  Utils.float2String (CO, temp, 3);
  strcat(data,temp);
  strcat(data,"&co2=");    
  Utils.float2String (CO2, temp, 3);
  strcat(data,temp);
  strcat(data,"&pressure=");    
  Utils.float2String (pressure, temp, 3);
  strcat(data,temp);
  strcat(data,"&humidity=");       
  Utils.float2String (humidity, temp, 3);
  strcat(data,temp);
  strcat(data,"&temperature=");       
  Utils.float2String (temperature, temp, 3);
  strcat(data,temp);
  strcat(data,"&pm1=");
  Utils.float2String (PM1, temp, 3);
  strcat(data,temp);
  strcat(data,"&pm25=");
  Utils.float2String (PM25, temp, 3);
  strcat(data,temp);
  strcat(data,"&pm10=");
  Utils.float2String (PM10, temp, 3);
  strcat(data,temp);      
  USB.println(data);
  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////
  error = _4G.ON();
  if (error == 0)
  {
    USB.println(F("1. 4G module ready..."));
    ////////////////////////////////////////////////
    // 2. HTTP POST
    ////////////////////////////////////////////////
    USB.print(F("2. HTTP POST request..."));
    // send the request
    error = _4G.http( Wasp4G::HTTP_POST, host, port, resource, data);
    // check the answer
    if (error == 0)
    {
      USB.print(F("Done. HTTP code: "));
      USB.println(_4G._httpCode);
      USB.print("Server response: ");
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.print(F("Failed. Error code: "));
      USB.println(error, DEC);
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("4G module not started"));
    USB.print(F("Error code: "));
    USB.println(error, DEC);
  }
  ////////////////////////////////////////////////
  // 3. Powers off the 4G module
  ////////////////////////////////////////////////
  USB.println(F("3. Switch OFF 4G module"));
  _4G.OFF();
  ////////////////////////////////////////////////
  // 4. Sleep
  ////////////////////////////////////////////////
  USB.println(F("4. Enter deep sleep..."));
  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.println(F("5. Wake up!!\n\n"));
}
