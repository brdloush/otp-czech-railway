#!/bin/bash

# Build overpass server containing recent czech OSM data filtered to only contain rail data + all highways
docker build -t otp-czech-overpass . -f Dockerfile-overpass

# Initialize the overpass server, so it can be started and queried later. 
# Once the OSM data get processed, the docker container stops automatically.
OVERPASS_DATA_DIR="$(pwd)/overpass-data"
docker run \
  -e OVERPASS_META=yes -e OVERPASS_MAX_TIMEOUT=10000 \
  -e OVERPASS_MODE=init \
  -e OVERPASS_PLANET_URL=file:///osm/czech-republic-pubtran-highways.osm.bz2 \
  -e OVERPASS_RULES_LOAD=10 \
  -v $OVERPASS_DATA_DIR:/db \
  -p 12345:80 \
  -i -t \
  --name overpass_czech_republic_build otp-czech-overpass

# run overpass server and wait for its start
docker start overpass_czech_republic_build

OVERPASS_RUNNING=0
while [ $OVERPASS_RUNNING == "0" ]; do
  echo "Waiting for overpass server startup. OVERPASS_RUNNING=$OVERPASS_RUNNING"
  sleep 1
  OVERPASS_RUNNING=`docker logs overpass_czech_republic_build | grep "overpass_dispatch entered RUNNING state" | wc -l`    
done
echo "Finished waiting, OVERPASS_RUNNING=$OVERPASS_RUNNING"

# exit 0

read -r -d '' OVERPASS_QUERY << EOM
[out:xml][timeout:10000][maxsize:4294967296];
node["railway"~"station|halt|stop"]->.a;
(
way(around.a: 500)[~"^(railway|highway)$"~".+"];
node(w);
);
out geom;
EOM

OVERPASS_QUERY_ENCODED=`echo "$OVERPASS_QUERY" | perl -pe 's/([^a-zA-Z0-9_.!~*()'\''-])/sprintf("%%%02X", ord($1))/ge'`

# execute the overpass query # 0h11m, 664MB osm file
curl 'http://localhost:12345/api/interpreter' \
  -H 'Accept: */*' \
  -H 'Accept-Language: cs,en;q=0.9,cs-CZ;q=0.8' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H 'Origin: https://overpass-turbo.osm.ch' \
  -H 'Pragma: no-cache' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: cross-site' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Google Chrome";v="105", "Not)A;Brand";v="8", "Chromium";v="105"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  --data-raw "data=$OVERPASS_QUERY_ENCODED" \
  --compressed > work/czech-republic-pubtran-and-1km-highways.osm

kill the temporary docker image
docker kill overpass_czech_republic_build
# remove the temporary docker image
docker rm overpass_czech_republic_build
