# IRISDEV Docker Template

A lightweight InterSystems IRIS template. It builds on the **IRIS Community
Edition** image, creates an `IRISDEV` namespace, and loads any ObjectScript
source under [src/](src/) into it at build time.

Inspired by the community [objectscript-docker-template](https://github.com/intersystems-community/objectscript-docker-template)
and [iris-interoperability-template](https://github.com/intersystems-community/iris-interoperability-template),
trimmed down (no ZPM / module.xml packaging) for a minimal start.

## Base image

`intersystemsdc/iris-community:latest` — currently maps to IRIS **2026.1**
(the latest GA). To pin a specific version:

```bash
docker compose build --build-arg IMAGE=intersystemsdc/iris-community:2026.1
```

## Prerequisites

- Docker + Docker Compose

## Quick start

```bash
# Build and start
docker compose up -d --build

# Follow logs
docker compose logs -f
```

Then open the **Management Portal**: http://localhost:52773/csp/sys/UtilHome.csp
(default dev credentials `_SYSTEM` / `SYS`).

## What gets set up

- A dedicated **`IRISDEV`** namespace with its own database.
- Embedded Python `%Service_CallIn` enabled.
- Passwords set to non-expiring (dev convenience).
- Everything under [src/](src/) loaded into `IRISDEV`.

## Try it

Open an IRIS session in the container:

```bash
docker compose exec iris iris session iris -U IRISDEV
```

```objectscript
do ##class(dc.sample.ObjectScript).Test()
```

## Ports

| Port  | Purpose                        |
|-------|--------------------------------|
| 1972  | Superserver (SQL / JDBC / ODBC)|
| 52773 | Management Portal / web        |

## Layout

```
.
├── Dockerfile           # builds on iris-community, runs iris.script
├── docker-compose.yml   # service definition + port mapping
├── iris.script          # creates IRISDEV namespace, loads src
├── merge.cpf            # config merge applied on startup
└── src/                 # your ObjectScript classes
    └── dc/sample/ObjectScript.cls
```

## Reloading source during development

The project is mounted at `/home/irisowner/dev`, so edit files under `src/`
and reload without rebuilding:

```bash
docker compose exec iris iris session iris -U IRISDEV \
  "##class(%SYSTEM.OBJ).LoadDir(\"/home/irisowner/dev/src\",\"ck\",,1)"
```
