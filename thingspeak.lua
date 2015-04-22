-- Measure temperature, humidity and post data to thingspeak.com
-- 2014 OK1CDJ
-- DHT11 code is from esp8266.com
---Sensor DHT11 is conntected to GPIO0
pin = 3

Humidity = 0
HumidityDec=0
Temperature = 0
TemperatureDec=0
Checksum = 0
ChecksumTest=0


sensorType="dht11"          -- set sensor type dht11 or dht22
 
    PIN = 3 --  data pin, GPIO0
    humi=0
    temp=0
    --load DHT module for read sensor
function ReadDHT()
    dht=require("testdht")
    dht.read(PIN)
    chck=1
    h=dht.getHumidity()
    t=dht.getTemperature()
    if h==nil then h=0 chck=0 end
    if sensorType=="dht11"then
        humi=h/256
        temp=t/256
    else
        humi=h/10
        temp=t/10
    end
    fare=(temp*9/5+32)
    print("Humidity:    "..humi.."%")
    print("Temperature: "..temp.." deg C")
    -- release module
    dht=nil
    package.loaded["testdht"]=nil
end




--- Get temp and send data to thingspeak.com
function sendData()
ReadDHT()
-- conection to thingspeak.com
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
conn:send("GET /update?key=8SM299R6WUJ323YY &field1="..temp.."."..TemperatureDec.."&field2="..humi.."."..HumidityDec.." HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
                      print("Got disconnection...")
  end)
end
-- send data every X ms to thing speak


tmr.alarm(2, 60000, 1, function() sendData() end )
