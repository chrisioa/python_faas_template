import requests
import json
 
 
response = requests.post("http://192.168.1.215:8080/function/db-prepare", '{"sensor_id": 3, "type": "SensorMock", "measurements": [{"name": "temperature", "value": -23.0, "unit": "\u00b0C"}, {"name": "humidity", "value": -60.0, "unit": "\u00b0C"}], "hostname": "1ec3f4c24036", "device_id": "RPiDev1", "building": "L9", "room": "Living Room", "measurements_name":"Temp & Humidity", "timestamp": 1548262139}')
influxdb_format=response.json()
print("########## INFLUXDB JSON READY FOR DB, FAASIFIED BABY!\n{}".format(str(influxdb_format))) 
