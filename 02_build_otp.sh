#!/bin/bash

# build the final image
docker build -t otp-czech-railway --build-arg build_date=`date -I` .
