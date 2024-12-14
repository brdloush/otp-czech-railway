#!/bin/bash

# copy version info
if [ -d /version-info ]; then
  cp /build-datetime /version-info/otp-buildtime
fi

# run OTP as usual
java $JAVA_OPTS -cp @/app/jib-classpath-file @/app/jib-main-class-file /var/otp-czech-republic $@