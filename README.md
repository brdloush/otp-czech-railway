# otp-czech-railway

> **WARNING !**
You should be aware that this docker image is very crude and I'm only using it for a personal pet project. Still, it might help you by providing a basic working prototype.

## Purpose of this image

This is a simple pre-baked docker image of `OpenTripPlanner`, containing:

- OSM data for railway stops/stations + highways in 1km surrounding of mentioned stops/stations
- railway GTFS routing data for Czech Republic.

The image can be used as a standalone "batteries included" REST API server which you can use for

- searching for routes between railway stations/stops
- generating Isochrone vector layers from a specific station (ie. map overlay showing how far you can get in 1,2,3,4,5 hours..)

The image is based on [urbica/docker-otp](https://github.com/urbica/docker-otp) and uses the [gtfscr/GVD2022](https://github.com/gtfscr/GVD2022) scripts to prepare fresh GTFS data off a rather non-standard format of czech railway timetables.

## Minimum requirements

I'm running this image successfully (under very small load!!!) on a 2GB RAM VPS magine, which also run a few more containers of my pet project application.

At the moment, I'm using a `JAVA_OPTIONS=-Xmx1500m` environment property for my OTP container. This value currently seems to be a reasonable minimum amount of heap that the OTP server needs for this custom-tailored czech-republic routing graph.

## Building

Currently the building is splitted into 2 steps:

`01_build_osm.sh`
- fetches OSM data for Czech Republic
- filters the data, so that only roads & railway-related information is retained for faster processing
- uses overpass api to only retain road network in close proximity of railroad stops

`02_build_otp.sh`
- uses pre-built output of `01_build_osm.sh`
- uses `brdloush/GVD2022` scripts to download recent railroad routing timetables & converts them to GTFS
- builds a standalone docker image containing OpenTripPlanner + routing data (+ roads in proximity of stops)

## Sample usage:

```bash
docker run --rm -it -p 8081:8080 -e JAVA_OPTIONS=-Xmx1500m brdloush/otp-czech-railway --server --autoScan --verbose
```

Once started, you can lookup stops ([docs here](http://dev.opentripplanner.org/apidoc/1.0.0/resource_GeocoderResource.html)):

```bash
curl "http://localhost:8081/otp/routers/default/geocode?query=Benešov%20u%20Prahy" | jq .
```
```json
[
  {
    "lat": 49.78136,
    "lng": 14.68183,
    "description": "stop Benešov u Prahy ",
    "id": "1_5455106"
  },
  {
    "lat": 50.15949,
    "lng": 14.3984,
    "description": "stop Roztoky u Prahy ",
    "id": "1_5454466"
  },
  {
    "lat": 49.87935,
    "lng": 14.42852,
    "description": "stop Petrov u Prahy ",
    "id": "1_5455726"
  },
  {
    "lat": 49.87803,
    "lng": 14.49997,
    "description": "stop Jílové u Prahy ",
    "id": "1_5455736"
  },
  {
    "lat": 50.23711,
    "lng": 14.49908,
    "description": "stop Kojetice u Prahy ",
    "id": "1_5454716"
  },
  {
    "lat": 50.20574,
    "lng": 14.5136,
    "description": "stop Měšice u Prahy ",
    "id": "1_5454726"
  },
  {
    "lat": 49.91014,
    "lng": 14.72024,
    "description": "stop Mirošovice u Prahy ",
    "id": "1_5455036"
  },
  {
    "lat": 50.03941,
    "lng": 14.24263,
    "description": "stop Rudná u Prahy ",
    "id": "1_5454916"
  },
  {
    "lat": 50.10487,
    "lng": 14.20926,
    "description": "stop Hostouň u Prahy ",
    "id": "1_5454076"
  },
  {
    "lat": 49.73081,
    "lng": 14.80548,
    "description": "stop Městečko u Benešova ",
    "id": "1_5455326"
  }
]
```

And also you can look up transit routes ([docs here](http://dev.opentripplanner.org/apidoc/1.0.0/resource_PlannerResource.html)):

```bash
curl "http://localhost:8081/otp/routers/default/plan?fromPlace=49.78136,14.68183,&toPlace=50.36118,13.8228,&time=11:30&date=04-29-2022&numItineraries=1" | jq .
```
```json
{
  "requestParameters": {
    "date": "04-29-2022",
    "fromPlace": "49.78136,14.68183,",
    "toPlace": "50.36118,13.8228,",
    "time": "11:30",
    "numItineraries": "1"
  },
  "plan": {
    "date": 1651224600000,
    "from": {
      "name": "Origin",
      "lon": 14.68183,
      "lat": 49.78136,
      "orig": "",
      "vertexType": "NORMAL"
    },
    "to": {
      "name": "Destination",
      "lon": 13.8228,
      "lat": 50.36118,
      "orig": "",
      "vertexType": "NORMAL"
    },
    "itineraries": [
      {
        "duration": 11192,
        "startTime": 1651225739000,
        "endTime": 1651236931000,
        "walkTime": 0,
        "transitTime": 9990,
        "waitingTime": 1202,
        "walkDistance": 0,
        "walkLimitExceeded": false,
        "elevationLost": 0,
        "elevationGained": 0,
        "transfers": 2,
        "legs": [
          {
            "startTime": 1651225740000,
            "endTime": 1651228200000,
            "departureDelay": 0,
            "arrivalDelay": 0,
            "realTime": false,
            "distance": 39934.6104302931,
            "pathway": false,
            "mode": "RAIL",
            "route": "722",
            "agencyName": "České dráhy, a.s.",
            "agencyUrl": "http://",
            "agencyTimeZoneOffset": 7200000,
            "routeType": 2,
            "routeId": "1:5982",
            "interlineWithPreviousLeg": false,
            "agencyId": "1154",
            "tripId": "1:5982",
            "serviceDate": "20220429",
            "from": {
              "name": "Benešov u Prahy",
              "stopId": "1:5455106",
              "lon": 14.68183,
              "lat": 49.78136,
              "departure": 1651225740000,
              "orig": "",
              "stopIndex": 6,
              "stopSequence": 48,
              "vertexType": "TRANSIT",
              "boardAlightType": "DEFAULT"
            },
            "to": {
              "name": "Praha hl. n.",
              "stopId": "1:5457076",
              "lon": 14.43547,
              "lat": 50.08264,
              "arrival": 1651228200000,
              "departure": 1651229160000,
              "stopIndex": 9,
              "stopSequence": 69,
              "vertexType": "TRANSIT",
              "boardAlightType": "DEFAULT"
            },
            "legGeometry": {
              "points": "o|ynHmprxA{zu@bza@_PtbJcmB|cA",
              "length": 4
            },
            "routeShortName": "722",
            "routeLongName": "R 722 Vltava",
            "rentedBike": false,
            "flexDrtAdvanceBookMin": 0,
            "duration": 2460,
            "transitLeg": true,
            "steps": []
          },
          {
            "startTime": 1651229160000,
            "endTime": 1651233480000,
            "departureDelay": 0,
            "arrivalDelay": 0,
            "realTime": false,
            "distance": 70589.90567414016,
            "pathway": false,
            "mode": "RAIL",
            "route": "688",
            "agencyName": "České dráhy, a.s.",
            "agencyUrl": "http://",
            "agencyTimeZoneOffset": 7200000,
            "routeType": 2,
            "routeId": "1:18440",
            "interlineWithPreviousLeg": false,
            "agencyId": "1154",
            "tripId": "1:18440",
            "serviceDate": "20220429",
            "from": {
              "name": "Praha hl. n.",
              "stopId": "1:5457076",
              "lon": 14.43547,
              "lat": 50.08264,
              "arrival": 1651228200000,
              "departure": 1651229160000,
              "stopIndex": 0,
              "stopSequence": 1,
              "vertexType": "TRANSIT",
              "boardAlightType": "DEFAULT"
            },
            "to": {
              "name": "Lovosice",
              "stopId": "1:5455859",
              "lon": 14.0595,
              "lat": 50.50948,
              "arrival": 1651233480000,
              "departure": 1651233720000,
              "stopIndex": 7,
              "stopSequence": 42,
              "vertexType": "TRANSIT",
              "boardAlightType": "DEFAULT"
            },
            "legGeometry": {
              "points": "owtpHulbwA_nDoYaIxqGerWv~Ny}h@ihH`eDx}QktKboUkpBboP",
              "length": 8
            },
            "routeShortName": "688",
            "routeLongName": "R 688 Labe",
            "rentedBike": false,
            "flexDrtAdvanceBookMin": 0,
            "duration": 4320,
            "transitLeg": true,
            "steps": []
          },
          {
            "startTime": 1651233720000,
            "endTime": 1651236930000,
            "departureDelay": 0,
            "arrivalDelay": 0,
            "realTime": false,
            "distance": 32016.87464352415,
            "pathway": false,
            "mode": "RAIL",
            "route": "6108",
            "agencyName": "České dráhy, a.s.",
            "agencyUrl": "http://",
            "agencyTimeZoneOffset": 7200000,
            "routeType": 2,
            "routeId": "1:645",
            "interlineWithPreviousLeg": false,
            "agencyId": "1154",
            "tripId": "1:3274",
            "serviceDate": "20220429",
            "from": {
              "name": "Lovosice",
              "stopId": "1:5455859",
              "lon": 14.0595,
              "lat": 50.50948,
              "arrival": 1651233480000,
              "departure": 1651233720000,
              "stopIndex": 13,
              "stopSequence": 19,
              "vertexType": "TRANSIT",
              "boardAlightType": "DEFAULT"
            },
            "to": {
              "name": "Louny",
              "stopId": "1:5454599",
              "lon": 13.8228,
              "lat": 50.36118,
              "arrival": 1651236930000,
              "orig": "",
              "stopIndex": 27,
              "stopSequence": 38,
              "vertexType": "TRANSIT",
              "boardAlightType": "DEFAULT"
            },
            "legGeometry": {
              "points": "gchsH{~xtAv}@vqC|aBkThnBlJrsCokExjAzy@jxBld@fQfmBbv@hyCzDvaEoOtiDjrCxmBbfBb~E`DzaFgI|bG",
              "length": 15
            },
            "routeShortName": "6108",
            "routeLongName": "Os 6108",
            "rentedBike": false,
            "flexDrtAdvanceBookMin": 0,
            "duration": 3210,
            "transitLeg": true,
            "steps": []
          }
        ],
        "tooSloped": false
      }
    ]
  },
  "debugOutput": {
    "precalculationTime": 46,
    "pathCalculationTime": 120,
    "pathTimes": [
      120
    ],
    "renderingTime": 1,
    "totalTime": 167,
    "timedOut": false
  },
  "elevationMetadata": {
    "ellipsoidToGeoidDifference": 46.996143281244606,
    "geoidElevation": false
  }
}
```

More concise example:

```curl
curl "http://localhost:8081/otp/routers/default/plan?fromPlace=49.78136,14.68183,&toPlace=50.36118,13.8228,&time=11:30&date=04-29-2022&numItineraries=1" | jq -r '.plan.itineraries | .[0] | .legs | .[] | {"from":.from.name, "departure": .from.departure |  (. / 1000) | strftime("%Y-%m-%d %H:%M UTC"), "to": .to.name, "arrival": .to.arrival | (. / 1000) | strftime("%Y-%m-%d %H:%M UTC")}'
```
```json
{
  "from": "Benešov u Prahy",
  "departure": "2022-04-29 09:49 UTC",
  "to": "Praha hl. n.",
  "arrival": "2022-04-29 10:30 UTC"
}
{
  "from": "Praha hl. n.",
  "departure": "2022-04-29 10:46 UTC",
  "to": "Lovosice",
  "arrival": "2022-04-29 11:58 UTC"
}
{
  "from": "Lovosice",
  "departure": "2022-04-29 12:02 UTC",
  "to": "Louny",
  "arrival": "2022-04-29 12:55 UTC"
}
```

# Special thanks

A huge thanks goes to [gtfscr/GVD2022](https://github.com/gtfscr/GVD2022).
