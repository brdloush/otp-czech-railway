FROM ubuntu:22.04 AS build-dataset-stage
RUN apt-get update && apt-get install -y git osmium-tool wget make zip unzip python3
RUN mkdir -p /graphs/czech-republic
RUN mkdir -p /work/GVD2022
# download OSM dataset from czech republic
RUN wget https://download.geofabrik.de/europe/czech-republic-latest.osm.pbf -P work 
# make simplified pbf
RUN osmium tags-filter work/czech-republic-latest.osm.pbf n/railway=halt,station,stop,platform -o graphs/czech-republic/czech-republic-pubtran.osm.pbf -f pbf,add_metadata=false --overwrite
# Downloads and build fresh version of GVD2022
ENV BUILD=2
RUN cd /work; git clone https://github.com/brdloush/GVD2022.git; cd /work/GVD2022; ./download_dirlisting_downloader.sh; ./down.sh;
RUN cd /work/GVD2022; ./make.sh;
RUN cp /work/GVD2022/gtfs/vlakyCR.zip ./graphs/czech-republic/vlakyCR.zip
RUN rm -rf work

FROM ubuntu:22.04 AS convert-osm-to-pbf
ENV BUILD_NUM=3
RUN mkdir /work
RUN apt-get update && apt-get install -y osmium-tool
ADD work/czech-republic-pubtran-and-1km-highways.osm /work/czech-republic-pubtran-and-1km-highways.osm
RUN cd /work; osmium cat -o czech-republic-pubtran-and-1km-highways.osm.pbf czech-republic-pubtran-and-1km-highways.osm


FROM brdloush/docker-otp:latest
RUN mkdir -p /var/otp/graphs/czech-republic
COPY --from=convert-osm-to-pbf /work/czech-republic-pubtran-and-1km-highways.osm.pbf /var/otp/graphs/czech-republic
COPY --from=build-dataset-stage /graphs/czech-republic/vlakyCR.zip /var/otp/graphs/czech-republic
ENV BUILD=3
RUN export JAVA_OPTIONS="-Xmx10g -Xms10g --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED"; otp --build /var/otp/graphs/czech-republic
RUN date --utc +%FT%T.000Z > /build-datetime
COPY copy-version-info.sh /opt/otp/copy-version-info.sh
RUN chmod +x /opt/otp/copy-version-info.sh
ENV INIT_SCRIPT=./copy-version-info.sh
