# IRISDEV Docker Template

A lightweight InterSystems IRIS template. It builds on the **IRIS Community
Edition** image, creates an `IRISDEV` namespace, and loads any ObjectScript
source under [src/](src/) into it **on startup**. IRIS data is persisted
across rebuilds via **Durable %SYS**.

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
- Everything under [src/](src/) loaded into `IRISDEV` on every startup.

## Data persistence (Durable %SYS)

IRIS instance data (databases, configuration, logs) is relocated to the
`iris-data` named volume via `ISC_DATA_DIRECTORY`, so it survives
`docker compose down` and image rebuilds. The `IRISDEV` namespace is created
at first startup directly in the durable directory.

To wipe all IRIS data and start fresh:

```bash
docker compose down -v   # -v removes the iris-data volume
```

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
├── Dockerfile           # builds on iris-community (init runs at startup)
├── docker-compose.yml   # service def, ports, Durable %SYS + startup hook
├── iris.script          # creates IRISDEV namespace, loads src (idempotent)
├── merge.cpf            # config merge applied on startup
└── src/                 # your ObjectScript classes
    └── dc/sample/ObjectScript.cls
```

## Reloading source during development

`src/` is loaded automatically on every `docker compose up` / restart. For a
faster inner loop without restarting the container, either use the VS Code
InterSystems ObjectScript extension (compile-on-save), or reload manually:

```bash
docker compose exec iris iris session iris -U IRISDEV \
  "##class(%SYSTEM.OBJ).LoadDir(\"/home/irisowner/dev/src\",\"ck\",,1)"
```
