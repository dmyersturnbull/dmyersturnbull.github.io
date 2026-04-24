---
tags:
  - Docker
---

# Docker conventions

Consider using a linter such as [hadolint](https://github.com/hadolint/hadolint).

## `ENV` commands

Break `ENV` commands into one line per command.
`ENV` no longer adds a layer in new Docker versions,
so there is no need to chain them on a single line.

## Labels

Use
[Open Containers labels](https://github.com/opencontainers/image-spec/blob/master/annotations.md),
at least including

- `org.opencontainers.image.version`
- `org.opencontainers.image.vendor`
- `org.opencontainers.image.title`
- `org.opencontainers.image.url`

## Multistage builds

Where applicable, use a multistage build to separate _build-time_ and _runtime_,
thereby keeping final images small.
For example, when using Maven, Maven is only needed to assemble, not to run.

Here, `maven:3-eclipse-temurin-25` is used as a base image,
Maven is used to compile and build a JAR artifact,
and everything but the JAR is discarded.
`eclipse-temurin:25` is used as the runtime base image, and only the JAR file is needed.

```Docker
FROM maven:3-eclipse-temurin-25 AS build
WORKDIR /root
RUN --mount=type=cache mvn package

FROM eclipse-temurin:25 AS run
ARG JAR_FILE=target/*.jar
COPY --from=build $JAR_FILE my-app.jar
EXPOSE 443
ENTRYPOINT java -jar my-app.jar
```
