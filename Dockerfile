FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

#
# Basic Parameters
#
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="2.3.1"
ARG PKG="grafana-reporter"
ARG SRC="github.com/IzakMarais/reporter"
ARG GO_VER="1.16.7"
ARG GO_SRC="https://golang.org/dl/go${GO_VER}.${OS}-${ARCH}.tar.gz"
ARG TEX_SRC="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
ARG UID="472"

#
# Some important labels
#
LABEL ORG="Armedia LLC"
LABEL MAINTAINER="Armedia Devops Team <devops@armedia.com>"
LABEL APP="Grafana Reporter"
LABEL VERSION="${VER}"

#
# Create the required user
#
RUN useradd --system --uid ${UID} --user-group grafana

#
# Set the Go environment
#
ENV GOROOT="/usr/local/go"
ENV GOPATH="/go"
ENV PATH="${PATH}:${GOROOT}/bin"

#
# Install the requisite packages for the build and runtime
#
RUN yum -y update && \
    yum -y install \
        git \
        texlive-collection-basic \
        texlive-collection-fontsrecommended \
        texlive-collection-htmlxml \
        texlive-collection-latex \
        texlive-collection-latexrecommended \
        texlive-collection-xetex

#
# Download and install go
#
RUN curl -L "${GO_SRC}" -o - | tar -C "/usr/local" -xzf -

#
# Build the reporter
#
WORKDIR "${GOROOT}"

RUN go get "${SRC}/cmd/grafana-reporter"
RUN go install -v "${SRC}/cmd/grafana-reporter@v${VER}"
RUN cp -vi "${GOPATH}/bin/grafana-reporter" "/usr/local/bin"

#
# Copy the main executable over
#
COPY /startup.sh /
RUN chmod ug+rwx,o-rwx /startup.sh

USER        grafana
EXPOSE      8686
VOLUME      [ "/templates" ]
ENTRYPOINT  [ "/startup.sh" ]
