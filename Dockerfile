FROM ubuntu:22.04 AS build-dataset-stage
RUN apt-get update && apt-get install -y git osmium-tool wget make zip unzip
RUN mkdir -p /graphs/czech-republic
RUN mkdir -p /work/GVD2022
# download OSM dataset from czech republic
RUN wget https://download.geofabrik.de/europe/czech-republic-latest.osm.pbf -P work 
# make simplified pbf
RUN osmium tags-filter work/czech-republic-latest.osm.pbf n/railway=halt,station,platform -o graphs/czech-republic/czech-republic-pubtran.osm.pbf -f pbf,add_metadata=false --overwrite
# Downloads and build fresh version of GVD2022
RUN cd /work; git clone https://github.com/brdloush/GVD2022.git; cd /work/GVD2022; ./down.sh;
#RUN cd /work; git clone https://github.com/gtfscr/GVD2022.git; cd /work/GVD2022; ./down.sh;
RUN apt-get install -y python3
RUN cd /work/GVD2022; ./make.sh;
RUN cp /work/GVD2022/gtfs/vlakyCR.zip ./graphs/czech-republic/vlakyCR.zip
RUN rm -rf work

FROM urbica/otp:latest
COPY --from=build-dataset-stage /graphs/czech-republic /var/otp/graphs/czech-republic
RUN otp --build /var/otp/graphs/czech-republic
