FROM debian:stable-slim AS builder

# Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    tar \
 && rm -rf /var/lib/apt/lists/*

# Dirty download... Maybe there's a way to get the latest file automatically?
RUN curl --progress-bar 'https://ftp.halifax.rwth-aachen.de/eclipse/technology/epp/downloads/release/2019-09/R/eclipse-java-2019-09-R-linux-gtk-x86_64.tar.gz' | tar xzf - -C /opt

# ----------------------------------------------------------------------------

FROM debian:stable-slim

ARG UID=1000
ARG GID=1000
ARG USER=eclipse
ARG GROUP=eclipse

# Workaround for a bug causing installation of `default-jre` to fail.
# See: https://github.com/debuerreotype/docker-debian-artifacts/issues/24
RUN mkdir -p /usr/share/man/man1

# Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    default-jre \
    libgtk-3-0 \
 && rm -rf /var/lib/apt/lists/*

# Create unprivileged user to run Eclipse
# User's UID and GID should match the builder's IDs in order not to screw up the file permissions and ownerships.
RUN addgroup --gid 1000 $GROUP \
 && adduser --disabled-password --disabled-login --uid $UID --gid $GID --gecos '' $USER

# Get Eclipse from builder container
COPY --from=builder /opt /opt

USER $UID:$GID
ENTRYPOINT [ "/opt/eclipse/eclipse" ]
