FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

#
# Basic Parameters
#
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="2.3.1"
ARG PKG="grafana-reporter"
ARG SRC="github.com/IzakMarais/reporter/cmd/grafana-reporter"
ARG GO_VER="1.16.7"
ARG GO_SRC="https://golang.org/dl/go${GO_VER}.${OS}-${ARCH}.tar.gz"
ARG UID="root"

#
# Some important labels
#
LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Armedia Devops Team <devops@armedia.com>"
LABEL APP="Grafana Reporter"
LABEL VERSION="${VER}"

#
# Set the Go environment
#
ENV GOROOT="/usr/local/go"
ENV GOPATH="/go"
ENV PATH="${PATH}:${GOROOT}/bin"

WORKDIR "${GOROOT}"

#
# Install the requisite packages for the build
#
RUN yum -y update && \
    yum -y install \
        git \
        texlive \
        texlive-luatex \
        texlive-xetex  \
        perl-Tk \
        perl-Digest-MD5

#
# Download and install go
#
RUN curl -L "${GO_SRC}" -o - | tar -C "/usr/local" -xzf -

# Install the packages we'll need
RUN apk add --no-cache \
    texlive \
    texlive-xetex \
    texlive-luatex \
    texmf-dist \
    texmf-dist-latexextra \
    texmf-dist-pictures \
    texmf-dist-science \
    texmf-dist-formatsextra

RUN go get "${SRC}/cmd/grafana-reporter"
RUN go install -v "${SRC}/cmd/grafana-reporter@v${VER}"
RUN cp -vi "${GOPATH}/bin/grafana-reporter" "/usr/local/bin"

#
# Copy the executable over
#
COPY /startup.sh /
RUN chmod ug+rwx,o-rwx /startup.sh

USER        ${UID}
EXPOSE      8686
VOLUME      [ "/templates" ]
SHELL       [ "/bin/bash", "-c" ]
ENTRYPOINT  [ "/startup.sh" ]
