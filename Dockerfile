# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.13
ARG NGINX_VERSION=1.28.0

## BUILD IMAGE.
FROM gitlab.int.catalystcloud.nz:4567/catalystcloud/python/python:${PYTHON_VERSION}-slim AS build

# Install build dependencies.
RUN apt-get update \
    && apt-get install --yes \
        build-essential \
        git \
        python3-dev

# Install python dependencies.
COPY requirements.txt requirements.txt
RUN pip install --root-user-action=ignore --upgrade -r requirements.txt

# Build the website.
WORKDIR /docs
COPY . /docs
RUN make html

## DEPLOY IMAGE.
FROM gitlab.int.catalystcloud.nz:4567/catalystcloud/nginx:${NGINX_VERSION}

COPY ["nginx/nginx.conf", "/etc/nginx/nginx.conf"]
COPY --from=build ["/docs/build/html", "/usr/share/nginx/html"]

# The following labels need to be set as part of the docker build process.
#   org.opencontainers.image.created
#   org.opencontainers.image.revision
LABEL org.opencontainers.image.authors="CatalystCloud <https://wiki.int.catalystcloud.nz/>"
LABEL org.opencontainers.image.documentation="https://wiki.int.catalystcloud.nz/bin/view/Main/"
LABEL org.opencontainers.image.source="https://gitlab.int.catalystcloud.nz/catalystcloud/catalystcloud-docs/-/blob/master/Dockerfile"
LABEL org.opencontainers.image.version="2025.11"
LABEL org.opencontainers.image.licenses=""
LABEL org.opencontainers.image.description="Catalyst Cloud Docs"
LABEL org.opencontainers.image.title="catalystcloud-docs"
LABEL com.catalystcloud.image.build_example="docker build -t catalystcloud/catalystcloud-docs -f Dockerfile ."
LABEL com.catalystcloud.image.run_example="docker run -d --rm --name catalystcloud-docs -p 10080:80 gitlab.int.catalystcloud.nz:4567/catalystcloud/catalystcloud-docs:latest"

# Nginx listens on port 80.
EXPOSE 80
