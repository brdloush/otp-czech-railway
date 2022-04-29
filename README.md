# otp-czech-railway

This is a simple pre-baked docker image of OpenTripPlanner, containing railway OSM data and railway GTFS routing data for Czech Republic.

You should be aware that this docker image is very crude and I'm only using it for a personal pet project. Still, it might help you by providing a basic working prototype.

The image is based on `urbica/docker-otp` and uses the [gtfscr/GVD2022](https://github.com/gtfscr/GVD2022) scripts to prepare fresh GTFS data off a rather non-standard format of czech railway timetables.

Usage example:

```bash
docker run --rm -it -p 8081:8080 -e JAVA_OPTIONS=-Xmx1G otp-czech-railway --server --autoScan --verbose
```

Once started, you can lookup stops ([docs here](http://dev.opentripplanner.org/apidoc/1.0.0/resource_GeocoderResource.html)):

```bash
curl "http://localhost:8081/otp/routers/default/geocode?query=Benešov" | jq .
```
```json
[
    {
        "lat": 49.78136,
        "lng": 14.68183,
        "description": "stop Benešov u Prahy ",
        "id": "1_5455106"
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
        "duration": 11190,
        "startTime": 1651225740000,
        "endTime": 1651236930000,
        "walkTime": 0,
        "transitTime": 9990,
        "waitingTime": 1200,
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
            "routeId": "1:434",
            "interlineWithPreviousLeg": false,
            "agencyId": "1154",
            "tripId": "1:15245",
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
            "routeId": "1:613",
            "interlineWithPreviousLeg": false,
            "agencyId": "1154",
            "tripId": "1:613",
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
            "routeId": "1:1148",
            "interlineWithPreviousLeg": false,
            "agencyId": "1154",
            "tripId": "1:17238",
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
    "precalculationTime": 6,
    "pathCalculationTime": 69,
    "pathTimes": [
      68
    ],
    "renderingTime": 0,
    "totalTime": 75,
    "timedOut": false
  },
  "elevationMetadata": {
    "ellipsoidToGeoidDifference": 47.04927914337423,
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