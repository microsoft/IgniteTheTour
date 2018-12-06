# azure-iot-edge-bogus-data-generator
An IoT Edge Module that generates sample data using [Bogus](https://github.com/bchavez/Bogus)

[![Docker Build Status](https://dockerbuildbadges.quelltext.eu/status.svg?organization=toolboc&repository=azure-iot-edge-bogus-data-generator)](https://hub.docker.com/r/toolboc/azure-iot-edge-bogus-data-generator/builds) [![Docker Pulls](https://img.shields.io/docker/pulls/toolboc/azure-iot-edge-bogus-data-generator.svg?style=flat-square)](https://hub.docker.com/r/toolboc/azure-iot-edge-bogus-data-generator]/)

![Demo](https://raw.githubusercontent.com/toolboc/azure-iot-edge-bogus-data-generator/master/assets/demo.png)

## Getting Started
Modify the `CreateBogusData` method in `BogusDataFatory.cs` to customize the simulated data.  See the [Bogus README](https://github.com/bchavez/Bogus#the-great-c-example) for examples.

## Module Twin Properties

| Parameter      | Description |   Type        |
| -------------- | ------------| --------- |
| SendData      | Controls whether to send data (default: true) | Boolean  |
| SendInterval   | Interval to generate and send data (in seconds) | Integer |