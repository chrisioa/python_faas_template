import json
import logging
import os


def handle(req):
    """handle a request to the function
    Args:
        req (str): request body
    """
    print("Received the following request:\n" + str(req) + "\nConverting...")
  # jsonreq = json.loads(req)
    converter = InfluxDBConverter(req['measurements_name'])
    influxdb_json=converter.convert(req)
    print("Result of Conversion:\n" + str(influxdb_json))
    return influxdb_json



class InfluxDBConverter:

    def __init__(self, name):
        self.name = name

    def convert(self, data):
        influxdb_json = InfluxDBFormat(self.name)
        influxdb_json.add_tag("sensor_id", data['sensor_id'])
        influxdb_json.add_tag("type", data['type'])
        influxdb_json.add_tag("hostname", data['hostname'])
        influxdb_json.add_tag("device_id", data['device_id'])
        influxdb_json.add_tag("building", data['building'])
        influxdb_json.add_tag("room", data['room'])
        for mes in data['measurements']:
            influxdb_json.add_measurement(mes['name'], mes['value'])
        return influxdb_json

class InfluxDBFormat:
    def __init__(self, measurement):
        self.data = { "measurement": measurement, "tags": {}, "fields": {}}

    def add_tag(self, tag, value):
        self.data['tags'].update({tag: value})

    def add_measurement(self, name, value):
        self.data['fields'].update({name: value})

    def get(self):
        return [self.data]

    def __str__(self):
        return json.dumps(self.data, indent=2)

