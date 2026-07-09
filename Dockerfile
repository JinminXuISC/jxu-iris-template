# Latest IRIS Community image. Override with e.g.
#   docker build --build-arg IMAGE=intersystemsdc/iris-community:2026.1 .
ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE

WORKDIR /home/irisowner/dev

# Run the init script at build time: create the IRISDEV namespace and load src.
RUN --mount=type=bind,src=.,dst=. \
    iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly
