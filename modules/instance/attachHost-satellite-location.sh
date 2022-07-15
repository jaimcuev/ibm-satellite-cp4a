#!/usr/bin/env bash
cat << 'HERE' >>/usr/local/bin/ibm-host-attach.sh
#!/usr/bin/env bash
set -ex
mkdir -p /etc/satelliteflags
HOST_ASSIGN_FLAG="/etc/satelliteflags/hostattachflag"
if [[ -f "$HOST_ASSIGN_FLAG" ]]; then
	echo "host has already been assigned. need to reload before you try the attach again"
	exit 0
fi
set +x
HOST_QUEUE_TOKEN="36f402d0b9d68ec8862a50fc88e18bfb33662b05a177876bec3d4c27afc0c5901833a5391646ae353bc2120214226319c41c89f0f540d06ebea6322b807ada36b97dee9744c87c24ae563e0697b9b90ff45d5b4cb73b7de5dbb644d05aab4144e1f7bebfd2f1ebcb9133a738124abca680e9cf470dea380d23bda2490ec50c861161de00e0f402ed4a16a62f20271d59614610a0048031173ed4990ac687b5db2dfa5541a02432f424839010edf734fba5ae7837c00cb8676b06870e0dbda8ac9765d4d9328247201b03ea183cfb884d2b8a318a01a40d101b0b0ddebe6965dc461aca19075626bc21f4f0b0f9375b1332863d11a62b894f4fa71a397b7e6973"
set -x
ACCOUNT_ID="9458bdef68824bce8527346bce35d610"
CONTROLLER_ID="cb8tiq5w0ioqmaj1o8rg"
SELECTOR_LABELS='{}'
API_URL="https://origin.us-east.containers.cloud.ibm.com/"
REGION="us-east"

export HOST_QUEUE_TOKEN
export ACCOUNT_ID
export CONTROLLER_ID
export REGION

#shutdown known blacklisted services for Satellite (these will break kube)
set +e
systemctl stop -f iptables.service
systemctl disable iptables.service
systemctl mask iptables.service
systemctl stop -f firewalld.service
systemctl disable firewalld.service
systemctl mask firewalld.service
set -e

# ensure you can successfully communicate with redhat mirrors (this is a prereq to the rest of the automation working)
if [[ $(grep -ic "maipo" < /etc/redhat-release) -ne 0 ]]; then
    #RHEL 7
    yum install rh-python36 -y
    # shellcheck disable=SC1091
    source /opt/rh/rh-python36/enable
elif [[ $(grep -ic "ootpa" < /etc/redhat-release) -ne 0 ]]; then
    #RHEL 8
    yum install python38 -y
fi
mkdir -p /etc/satellitemachineidgeneration
if [[ ! -f /etc/satellitemachineidgeneration/machineidgenerated ]]; then
	rm -f /etc/machine-id
	systemd-machine-id-setup
	touch /etc/satellitemachineidgeneration/machineidgenerated
fi
#STEP 1: GATHER INFORMATION THAT WILL BE USED TO REGISTER THE HOST
HOSTNAME=$(hostname -s)
HOSTNAME=${HOSTNAME,,}
MACHINE_ID=$(cat /etc/machine-id)
CPUS=$(nproc)
MEMORY=$(grep MemTotal /proc/meminfo | awk '{print $2}')
export CPUS
export MEMORY

set +e
if grep -qi "coreos" < /etc/redhat-release; then
  OPERATING_SYSTEM="RHCOS"
elif grep -qi "maipo" < /etc/redhat-release; then
  OPERATING_SYSTEM="RHEL7"
elif grep -qi "ootpa" < /etc/redhat-release; then
  OPERATING_SYSTEM="RHEL8"
else
  echo "Operating System not supported"
  OPERATING_SYSTEM="UNKNOWN"
fi
set -e

if [[ "${OPERATING_SYSTEM}" != "RHEL7" && "${OPERATING_SYSTEM}" != "RHEL8" ]]; then
  echo "This script is only intended to run with a RHEL7 or RHEL8 operating system. Current operating system ${OPERATING_SYSTEM}. Going to continue on for backwards compatibility"
fi

export OPERATING_SYSTEM
SELECTOR_LABELS=$(echo "${SELECTOR_LABELS}" | python3 -c "import sys, json, os; z = json.load(sys.stdin); y = {\"cpu\": os.getenv('CPUS'), \"memory\": os.getenv('MEMORY'), \"os\": os.getenv('OPERATING_SYSTEM')}; z.update(y); print(json.dumps(z))")

set +e
export ZONE=""
export PROVIDER=""
export TOKEN=""
echo "Probing for AWS metadata"
gather_aws_token() {
	HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --max-time 10 -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
	HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
	HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
	if [[ "$HTTP_STATUS" -ne 200 ]]; then
		echo "bad return code"
		return 1
	fi
	if [[ -z "$HTTP_BODY" ]]; then
		echo "no token found"
		return 1
	fi
	echo "found aws access token"
	TOKEN="$HTTP_BODY"
}
gather_zone_info() {
	HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --max-time 10 -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
	HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
	HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
	# if a 401 retry without auth
	if [[ "$HTTP_STATUS" -eq 401 ]]; then
		echo "unable to get aws metadata with v2 metadata service, trying v1..."
		HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --max-time 10 http://169.254.169.254/latest/meta-data/placement/availability-zone)
		HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
		HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
	fi
	if [[ "$HTTP_STATUS" -ne 200 ]]; then
		echo "bad return code"
		return 1
	fi
	if [[ "$HTTP_BODY" =~ [^a-zA-Z0-9-] ]]; then
		echo "invalid zone format"
		return 1
	fi
	ZONE="$HTTP_BODY"
}
gather_aws_info() {
    if ! gather_aws_token; then
        return 1
    fi
    if ! gather_zone_info; then
        return 1
    fi
}
if gather_aws_info; then
	echo "aws metadata detected"
	PROVIDER="aws"
fi
if [[ -z "$ZONE" ]]; then
	echo "echo Probing for Azure Metadata"
	export LOCATION_INFO=""
	export AZURE_ZONE_NUMBER_INFO=""
	gather_location_info() {
		HTTP_RESPONSE=$(curl -H Metadata:true --noproxy "*" --write-out "HTTPSTATUS:%{http_code}" --max-time 10 "http://169.254.169.254/metadata/instance/compute/location?api-version=2021-01-01&format=text")
		HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
		HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
		if [[ "$HTTP_STATUS" -ne 200 ]]; then
			echo "bad return code"
			return 1
		fi
		if [[ "$HTTP_BODY" =~ [^a-zA-Z0-9-] ]]; then
			echo "invalid format"
			return 1
		fi
		LOCATION_INFO="$HTTP_BODY"
	}
	gather_azure_zone_number_info() {
		HTTP_RESPONSE=$(curl -H Metadata:true --noproxy "*" --write-out "HTTPSTATUS:%{http_code}" --max-time 10 "http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-01-01&format=text")
		HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
		HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
		if [[ "$HTTP_STATUS" -ne 200 ]]; then
			echo "bad return code"
			return 1
		fi
		if [[ "$HTTP_BODY" =~ [^a-zA-Z0-9-] ]]; then
			echo "invalid format"
			return 1
		fi
		AZURE_ZONE_NUMBER_INFO="$HTTP_BODY"
	}
	gather_zone_info() {
		if ! gather_location_info; then
			return 1
		fi
		if ! gather_azure_zone_number_info; then
			return 1
		fi
		if [[ -n "$AZURE_ZONE_NUMBER_INFO" ]]; then
		  ZONE="${LOCATION_INFO}-${AZURE_ZONE_NUMBER_INFO}"
		else
		  ZONE="${LOCATION_INFO}"
		fi
	}
	if gather_zone_info; then
		echo "azure metadata detected"
		PROVIDER="azure"
	fi
fi
if [[ -z "$ZONE" ]]; then
	echo "echo Probing for GCP Metadata"
	gather_zone_info() {
		HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --max-time 10 "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
		HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
		HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
		if [[ "$HTTP_STATUS" -ne 200 ]]; then
			echo "bad return code"
			return 1
		fi
		POTENTIAL_ZONE_RESPONSE=$(echo "$HTTP_BODY" | awk -F '/' '{print $NF}')
		if [[ "$POTENTIAL_ZONE_RESPONSE" =~ [^a-zA-Z0-9-] ]]; then
			echo "invalid zone format"
			return 1
		fi
		ZONE="$POTENTIAL_ZONE_RESPONSE"
	}
	if gather_zone_info; then
		echo "gcp metadata detected"
		PROVIDER="google"
	fi
fi
set -e
if [[ -n "$ZONE" ]]; then
	SELECTOR_LABELS=$(echo "${SELECTOR_LABELS}" | python3 -c "import sys, json, os; z = json.load(sys.stdin); y = {\"zone\": os.getenv('ZONE')}; z.update(y); print(json.dumps(z))")
fi
if [[ -n "$PROVIDER" ]]; then
	SELECTOR_LABELS=$(echo "${SELECTOR_LABELS}" | python3 -c "import sys, json, os; z = json.load(sys.stdin); y = {\"provider\": os.getenv('PROVIDER')}; z.update(y); print(json.dumps(z))")
fi
#Step 2: SETUP METADATA
cat <<EOF >register.json
{
"controller": "$CONTROLLER_ID",
"name": "$HOSTNAME",
"identifier": "$MACHINE_ID",
"labels": $SELECTOR_LABELS
}
EOF

set +e
#try to download and run host health check script
set +x
#first try to the satellite-health service is enabled
HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --retry 5 --retry-delay 10 --retry-max-time 60 \
        "${API_URL}satellite-health/api/v1/hello")
set -x
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
echo "$HTTP_STATUS"
if [[ "$HTTP_STATUS" -eq 200 ]]; then
        set +x
        HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --retry 20 --retry-delay 10 --retry-max-time 360 \
                "${API_URL}satellite-health/sat-host-check" -o /usr/local/bin/sat-host-check)
        set -x
        HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
        HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
        echo "$HTTP_BODY"
        echo "$HTTP_STATUS"
        if [[ "$HTTP_STATUS" -eq 200 ]]; then
                chmod +x /usr/local/bin/sat-host-check
                set +x
                timeout 5m /usr/local/bin/sat-host-check --region $REGION  --endpoint $API_URL
                set -x
        else
                echo "Error downloading host health check script [HTTP status: $HTTP_STATUS]"
        fi
else
        echo "Skipping downloading host health check script [HTTP status: $HTTP_STATUS]"
fi
set -e

set +x
#STEP 3: REGISTER HOST TO THE HOSTQUEUE. NEED TO EVALUATE HTTP STATUS 409 EXISTS, 201 created. ALL OTHERS FAIL.
HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --retry 100 --retry-delay 10 --retry-max-time 1800 -X POST \
	-H "X-Auth-Hostqueue-APIKey: $HOST_QUEUE_TOKEN" \
	-H "X-Auth-Hostqueue-Account: $ACCOUNT_ID" \
	-H "Content-Type: application/json" \
	-d @register.json \
	"${API_URL}v2/multishift/hostqueue/host/register")
set -x
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')

echo "$HTTP_BODY"
echo "$HTTP_STATUS"
if [[ "$HTTP_STATUS" -ne 201 ]]; then
	echo "Error [HTTP status: $HTTP_STATUS]"
	exit 1
fi

HOST_ID=$(echo "$HTTP_BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")

#STEP 4: WAIT FOR MEMBERSHIP TO BE ASSIGNED
while true; do
	set +ex
	ASSIGNMENT=$(curl --retry 100 --retry-delay 10 --retry-max-time 1800 -G -X GET \
		-H "X-Auth-Hostqueue-APIKey: $HOST_QUEUE_TOKEN" \
		-H "X-Auth-Hostqueue-Account: $ACCOUNT_ID" \
		-d controllerID="$CONTROLLER_ID" \
		-d hostID="$HOST_ID" \
		"${API_URL}v2/multishift/hostqueue/host/getAssignment")
	set -ex
	isAssigned=$(echo "$ASSIGNMENT" | python3 -c "import sys, json; print(json.load(sys.stdin)['isAssigned'])" | awk '{print tolower($0)}')
	if [[ "$isAssigned" == "true" ]]; then
		break
	fi
	if [[ "$isAssigned" != "false" ]]; then
		echo "unexpected value for assign retrying"
	fi
	sleep 10
done

#STEP 5: ASSIGNMENT HAS BEEN MADE. SAVE SCRIPT AND RUN
echo "$ASSIGNMENT" | python3 -c "import sys, json; print(json.load(sys.stdin)['script'])" >/usr/local/bin/ibm-host-agent.sh
export HOST_ID
ASSIGNMENT_ID=$(echo "$ASSIGNMENT" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")
cat <<EOF >/etc/satelliteflags/ibm-host-agent-vars
export HOST_ID=${HOST_ID}
export ASSIGNMENT_ID=${ASSIGNMENT_ID}
EOF
chmod 0600 /etc/satelliteflags/ibm-host-agent-vars
chmod 0700 /usr/local/bin/ibm-host-agent.sh
cat <<EOF >/etc/systemd/system/ibm-host-agent.service
[Unit]
Description=IBM Host Agent Service
After=network.target

[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/usr/local/bin/ibm-host-agent.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/ibm-host-agent.service
systemctl daemon-reload
systemctl start ibm-host-agent.service
touch "$HOST_ASSIGN_FLAG"
HERE

chmod 0700 /usr/local/bin/ibm-host-attach.sh
cat << 'EOF' >/etc/systemd/system/ibm-host-attach.service
[Unit]
Description=IBM Host Attach Service
After=network.target

[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/usr/local/bin/ibm-host-attach.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/ibm-host-attach.service
systemctl daemon-reload
systemctl enable ibm-host-attach.service
systemctl start ibm-host-attach.service
