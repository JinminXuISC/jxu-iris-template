# Latest IRIS Community image. Override with e.g.
#   docker build --build-arg IMAGE=intersystemsdc/iris-community:2026.1 .
ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE

WORKDIR /home/irisowner/dev

# Pre-create the Durable %SYS mount point owned by irisowner. When the empty
# `iris-data` named volume mounts onto /durable, Docker copies this directory's
# ownership into the volume, so IRIS (running as irisowner, not root) can
# create /durable/irissys. Without this the container crash-loops with
# "Durable folder: /durable/irissys does not exist, or cannot be created".
USER root
RUN mkdir -p /durable && chown irisowner:irisowner /durable
USER irisowner

# NOTE: Namespace creation and source loading are NOT run at build time.
# They run at *startup* via iris.script (wired up with `iris-main --after` in
# docker-compose.yml). This is required for Durable %SYS: build-time changes
# land in the image's mgr/ directory, but at runtime IRIS uses the persisted
# durable directory, so init must run there instead. Running on startup also
# means new files under src/ are imported and compiled on every `up`/restart.
