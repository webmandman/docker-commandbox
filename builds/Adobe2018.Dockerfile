FROM commandbox-base

LABEL maintainer "Jon Clausen <jclausen@ortussolutions.com>"
LABEL repository "https://github.com/Ortus-Solutions/docker-commandbox"

#Hard Code our engine environment
ENV CFENGINE adobe@2018.0.10+320417

# WARM UP THE SERVER
RUN ${BUILD_DIR}/util/warmup-server.sh