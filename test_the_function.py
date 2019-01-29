import requests
import json
 

response = requests.post("http://127.0.0.1:8080/function/db-prepare", '{"sensor_id": 3, "type": "SensorMock", "measurements": [{"name": "temperature", "value": 1.0, "unit": "\u00b0C"}, {"name": "humidity", "value": -120.0, "unit": "\u00b0C"}], "hostname": "1ec3f4c24036", "device_id": "RPiDev1", "building": "L9", "room": "Living Room", "measurements_name":"Temp & Humidity", "timestamp": 1548262139}')

print((response.text))

