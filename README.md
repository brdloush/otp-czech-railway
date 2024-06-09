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
- the final step which downloads the overpass query can take ~15 minutes (on XPS13 9370 laptop, ie Intel(R) Core(TM) i7-8550U)

`02_build_otp.sh`
- uses pre-built output of `01_build_osm.sh`
- uses `brdloush/GVD2022` scripts to download recent railroad routing timetables & converts them to GTFS
- builds a standalone docker image containing OpenTripPlanner + routing data (+ roads in proximity of stops)

## Sample usage:

```bash
docker run --rm -it -p 8081:8080 -e JAVA_OPTIONS=-Xmx1500m brdloush/otp-czech-railway --serve --load
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
DATE=`date -I` curl "http://localhost:8081/otp/routers/default/plan?fromPlace=49.78136,14.68183,&toPlace=50.36118,13.8228,&time=11:30&date=$DATE&numItineraries=1" | jq .
```
```json
{
  "requestParameters": {
    "date": "",
    "fromPlace": "49.78136,14.68183,",
    "toPlace": "50.36118,13.8228,",
    "time": "11:30",
    "numItineraries": "1"
  },
  "plan": {
    "date": 1717935623040,
    "from": {
      "name": "Origin",
      "lon": 14.68183,
      "lat": 49.78136,
      "vertexType": "NORMAL"
    },
    "to": {
      "name": "Louny",
      "stopId": "1:5454599",
      "lon": 13.8228,
      "lat": 50.36118,
      "vertexType": "TRANSIT"
    },
    "itineraries": [
      {
        "duration": 15054,
        "startTime": 1717935726000,
        "endTime": 1717950780000,
        "walkTime": 534,
        "transitTime": 11430,
        "waitingTime": 3090,
        "walkDistance": 607.63,
        "walkLimitExceeded": false,
        "generalizedCost": 17330,
        "elevationLost": 0,
        "elevationGained": 0,
        "transfers": 2,
        "fare": {
          "fare": {},
          "details": {}
        },
        "legs": [
          {
            "startTime": 1717935726000,
            "endTime": 1717936260000,
            "departureDelay": 0,
            "arrivalDelay": 0,
            "realTime": false,
            "distance": 607.63,
            "generalizedCost": 1008,
            "pathway": false,
            "mode": "WALK",
            "transitLeg": false,
            "route": "",
            "agencyTimeZoneOffset": 7200000,
            "interlineWithPreviousLeg": false,
            "from": {
              "name": "Origin",
              "lon": 14.68183,
              "lat": 49.78136,
              "departure": 1717935726000,
              "vertexType": "NORMAL"
            },
            "to": {
              "name": "Benešov u Prahy",
              "stopId": "1:5455106",
              "lon": 14.68271,
              "lat": 49.77969,
              "arrival": 1717936260000,
              "departure": 1717936260000,
              "vertexType": "TRANSIT"
            },
            "legGeometry": {
              "points": "g|ynHkorxAq@VENBXKNCGGAG?IDMFKJSPGDG@E@EAEAECEECECEAGEg@AE?G@I@G@GBEBEBCBCn@YzAu@PGj@Ip@SbAk@XQVQG]BIz@a@nAm@JGFFf@UMAOHE@Jl@Hl@Fb@IDi@E",
              "length": 55
            },
            "steps": [
              {
                "distance": 53.68,
                "relativeDirection": "DEPART",
                "streetName": "service road",
                "absoluteDirection": "NORTH",
                "stayOn": false,
                "area": false,
                "bogusName": true,
                "lon": 14.6816628,
                "lat": 49.7813275,
                "elevation": "",
                "walkingBike": false
              },
              {
                "distance": 498.38,
                "relativeDirection": "RIGHT",
                "streetName": "path",
                "absoluteDirection": "NORTH",
                "stayOn": true,
                "area": false,
                "bogusName": true,
                "lon": 14.6812529,
                "lat": 49.7816405,
                "elevation": "",
                "walkingBike": false
              },
              {
                "distance": 49.1,
                "relativeDirection": "LEFT",
                "streetName": "underpass",
                "absoluteDirection": "WEST",
                "stayOn": true,
                "area": false,
                "bogusName": true,
                "lon": 14.6833531,
                "lat": 49.7795855,
                "elevation": "",
                "walkingBike": false
              },
              {
                "distance": 6.49,
                "relativeDirection": "RIGHT",
                "streetName": "steps",
                "absoluteDirection": "NORTH",
                "stayOn": true,
                "area": false,
                "bogusName": true,
                "lon": 14.6827124,
                "lat": 49.7794311,
                "elevation": "",
                "walkingBike": false
              }
            ],
            "rentedBike": false,
            "walkingBike": false,
            "duration": 534
          },
          {
            "startTime": 1717936260000,
            "endTime": 1717938600000,
            "departureDelay": 0,
            "arrivalDelay": 0,
            "realTime": false,
            "distance": 40112.4,
            "generalizedCost": 2940,
            "pathway": false,
            "mode": "RAIL",
            "transitLeg": true,
            "route": "R 716 Vltava",
            "agencyName": "České dráhy, a.s.",
            "agencyUrl": "http://",
            "agencyTimeZoneOffset": 7200000,
            "routeType": 2,
            "routeId": "1:12710",
            "interlineWithPreviousLeg": false,
            "agencyId": "1:1154",
            "tripId": "1:12710",
            "serviceDate": "2024-06-09",
            "from": {
              "name": "Benešov u Prahy",
              "stopId": "1:5455106",
              "lon": 14.68271,
              "lat": 49.77969,
              "arrival": 1717936260000,
              "departure": 1717936260000,
              "stopIndex": 6,
              "stopSequence": 48,
              "vertexType": "TRANSIT"
            },
            "to": {
              "name": "Praha hl. n.",
              "stopId": "1:5457076",
              "lon": 14.43547,
              "lat": 50.08264,
              "arrival": 1717938600000,
              "departure": 1717939680000,
              "stopIndex": 9,
              "stopSequence": 69,
              "vertexType": "TRANSIT"
            },
            "legGeometry": {
              "points": "arynH}urxAiev@r_b@??sM|zI??ooBtkA",
              "length": 6
            },
            "steps": [],
            "routeShortName": "716",
            "routeLongName": "R 716 Vltava",
            "duration": 2340
          },
          {
            "startTime": 1717939680000,
            "endTime": 1717946970000,
            "departureDelay": 0,
            "arrivalDelay": 0,
            "realTime": false,
            "distance": 105862.37,
            "generalizedCost": 8970,
            "pathway": false,
            "mode": "RAIL",
            "transitLeg": true,
            "route": "R 608 Krušnohor",
            "agencyName": "České dráhy, a.s.",
            "agencyUrl": "http://",
            "agencyTimeZoneOffset": 7200000,
            "routeType": 2,
            "routeId": "1:13556",
            "interlineWithPreviousLeg": false,
            "agencyId": "1:1154",
            "tripId": "1:13556",
            "serviceDate": "2024-06-09",
            "from": {
              "name": "Praha hl. n.",
              "stopId": "1:5457076",
              "lon": 14.43547,
              "lat": 50.08264,
              "arrival": 1717938600000,
              "departure": 1717939680000,
              "stopIndex": 0,
              "stopSequence": 1,
              "vertexType": "TRANSIT"
            },
            "to": {
              "name": "Most",
              "stopId": "1:5453399",
              "lon": 13.65801,
              "lat": 50.51151,
              "arrival": 1717946970000,
              "departure": 1717948980000,
              "stopIndex": 5,
              "stopSequence": 73,
              "vertexType": "TRANSIT"
            },
            "legGeometry": {
              "points": "owtpHulbwA_nDoY??ecjBtglA??zmAb}h@??z`QndJ??~hGhhU",
              "length": 10
            },
            "steps": [],
            "routeShortName": "608",
            "routeLongName": "R 608 Krušnohor",
            "duration": 7290
          },
          {
            "startTime": 1717948980000,
            "endTime": 1717950780000,
            "departureDelay": 0,
            "arrivalDelay": 0,
            "realTime": false,
            "distance": 22808.29,
            "generalizedCost": 4412,
            "pathway": false,
            "mode": "RAIL",
            "transitLeg": true,
            "route": "Os 6737",
            "agencyName": "Die Länderbahn CZ s.r.o.",
            "agencyUrl": "http://",
            "agencyTimeZoneOffset": 7200000,
            "routeType": 2,
            "routeId": "1:10176",
            "interlineWithPreviousLeg": false,
            "agencyId": "1:3736",
            "tripId": "1:25126",
            "serviceDate": "2024-06-09",
            "from": {
              "name": "Most",
              "stopId": "1:5453399",
              "lon": 13.65801,
              "lat": 50.51151,
              "arrival": 1717946970000,
              "departure": 1717948980000,
              "stopIndex": 0,
              "stopSequence": 1,
              "vertexType": "TRANSIT"
            },
            "to": {
              "name": "Louny",
              "stopId": "1:5454599",
              "lon": 13.8228,
              "lat": 50.36118,
              "arrival": 1717950780000,
              "stopIndex": 6,
              "stopSequence": 8,
              "vertexType": "TRANSIT"
            },
            "legGeometry": {
              "points": "}ohsHqqjrAbk@_fG??djHqgA??xnHafA??f}DozH??hh@{}C??z{@}sC",
              "length": 12
            },
            "steps": [],
            "routeShortName": "6737",
            "routeLongName": "Os 6737",
            "duration": 1800
          }
        ],
        "tooSloped": false,
        "arrivedAtDestinationWithRentedBicycle": false
      }
    ]
  },
  "metadata": {
    "searchWindowUsed": 6600,
    "nextDateTime": 1717935780000,
    "prevDateTime": 1717929023000
  },
  "previousPageCursor": "MXxQUkVWSU9VU19QQUdFfDIwMjQtMDYtMDlUMTE6NDA6MjNafHw0MG18U1RSRUVUX0FORF9BUlJJVkFMX1RJTUV8ZmFsc2V8MjAyNC0wNi0wOVQxMjoyMjowNlp8MjAyNC0wNi0wOVQxNjozMzowMFp8MnwxNzMzMHw=",
  "nextPageCursor": "MXxORVhUX1BBR0V8MjAyNC0wNi0wOVQxMzoyNjowNlp8fDQwbXxTVFJFRVRfQU5EX0FSUklWQUxfVElNRXxmYWxzZXwyMDI0LTA2LTA5VDEyOjIyOjA2WnwyMDI0LTA2LTA5VDE2OjMzOjAwWnwyfDE3MzMwfA==",
  "debugOutput": {
    "precalculationTime": 208546,
    "directStreetRouterTime": 35569953,
    "transitRouterTime": 226226986,
    "filteringTime": 4065724,
    "renderingTime": 5746934,
    "totalTime": 271926062,
    "transitRouterTimes": {
      "tripPatternFilterTime": 31320263,
      "accessEgressTime": 6584711,
      "raptorSearchTime": 139594996,
      "itineraryCreationTime": 48663807
    }
  },
  "elevationMetadata": {
    "ellipsoidToGeoidDifference": 46.713641965970574,
    "geoidElevation": false
  }
}
```

More concise example:

```curl
DATE=`date -I` curl "http://localhost:8081/otp/routers/default/plan?fromPlace=49.78136,14.68183,&toPlace=50.36118,13.8228,&time=11:30&date=$DATE&numItineraries=1" | jq -r '.plan.itineraries | .[0] | .legs | .[] | {"from":.from.name, "departure": .from.departure |  (. / 1000) | strftime("%Y-%m-%d %H:%M UTC"), "to": .to.name, "arrival": .to.arrival | (. / 1000) | strftime("%Y-%m-%d %H:%M UTC")}'
```
```json
{
  "from": "Origin",
  "departure": "2024-06-09 12:22 UTC",
  "to": "Benešov u Prahy",
  "arrival": "2024-06-09 12:31 UTC"
}
{
  "from": "Benešov u Prahy",
  "departure": "2024-06-09 12:31 UTC",
  "to": "Praha hl. n.",
  "arrival": "2024-06-09 13:10 UTC"
}
{
  "from": "Praha hl. n.",
  "departure": "2024-06-09 13:28 UTC",
  "to": "Most",
  "arrival": "2024-06-09 15:29 UTC"
}
{
  "from": "Most",
  "departure": "2024-06-09 16:03 UTC",
  "to": "Louny",
  "arrival": "2024-06-09 16:33 UTC"
}
```

# Special thanks

A huge thanks goes to [gtfscr/GVD2022](https://github.com/gtfscr/GVD2022).
