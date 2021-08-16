#!/bin/bash

say() {
	/bin/echo -e "${@}"
}

err() {
	say "ERROR: ${@}" 1>&2
}

fail() {
	err "${@}"
	exit 1
}

PARAMS=()

# -ip string
#       Grafana IP and port. (default "localhost:3000")
if [ -n "${GRAFANA_URL}" ] ; then
	# TODO: Validate the host:port syntax?
	PARAMS+=("-ip" "${GRAFANA_URL}")
fi

# -grid-layout
#       Enable grid layout (-grid-layout=1). Panel width and height will be calculated based off Grafana gridPos width and height.
[ -n "${GRID_LAYOUT}" ] && PARAMS+=("-grid-layout=${GRID_LAYOUT}")

# -templates string
#       Directory for custom TeX templates. (default "templates/")
PARAMS+=("-templates" "/templates")

# -proto string
#       Grafana Protocol. Change to 'https://' if Grafana is using https. Reporter will still serve http. (default "http://")
GRAFANA_SSL="${GRAFANA_SSL,,}"
case "${GRAFANA_SSL}" in
	1 | y | yes | true | t | on ) GRAFANA_SSL="true" ;;
	0 | n | no | false | f | off ) GRAFANA_SSL="false" ;;
	* ) GRAFANA_SSL="false" ;;
esac
SSL_PROTO="http://"
${GRAFANA_SSL} && SSL_PROTO="https://"
PARAMS+=("-proto" "${SSL_PROTO}")

if "${GRAFANA_SSL}" ; then
	# -ssl-check
	#       Check the SSL issuer and validity. Set this to false if your Grafana serves https using an unverified, self-signed certificate. (default true)
	GRAFANA_SSL_CHECK="${GRAFANA_SSL_CHECK,,}"
	case "${GRAFANA_SSL_CHECK}" in
		1 | y | yes | true | t | on ) GRAFANA_SSL_CHECK="true" ;;
		0 | n | no | false | f | off ) GRAFANA_SSL_CHECK="false" ;;
		* ) GRAFANA_SSL_CHECK="true" ;;
	esac
	PARAMS+=("-ssl-check" "${GRAFANA_SSL_CHECK}")
fi

say "Executing with parameters ${PARAMS[@]}"
exec /usr/local/bin/grafana-reporter "${PARAMS[@]}"
