#!/bin/sh

ask_packstack () {
	openstack-config --get $PACKSTACK_ANSWERS general $1
}

log () {
	echo "$(date +%Y-%m-%d) $(basename $0) $1" >&2
}

die () {
	log "ERROR: $1"
	exit ${2:-1}
}

batchssh () {
	ssh -o BatchMode=yes -o StrictHostkeyChecking=no "$@"
}

install_havana_repo () {
	if ! rpm --quiet -q rdo-release-havana; then
		log "installing havana yum repository"
		yum -d1 -y install http://rdo.fedorapeople.org/openstack-havana/rdo-release-havana.rpm
	fi
}

upgrade_keystone () {
	log "start upgrading keystone"

	cat <<-EOF | batchssh root@$(ask_packstack CONFIG_CINDER_HOST) bash
	openstack-service stop keystone
	yum -d1 -y upgrade openstack-keystone\* python-keystone python-keystoneclient
	keystone-manage db_sync
	openstack-service start keystone
	EOF

	log "finished upgrading keystone"
}

upgrade_swift () {
	log "start upgrading swift"

	for host in $(ask_packstack CONFIG_SWIFT_STORAGE_HOSTS | tr , ' '); do
		cat <<-EOF | batchssh root@$host bash
		openstack-service stop swift
		yum -d1 -y upgrade openstack-swift\* python-swiftclient python-keystoneclient
		openstack-service start swift
		EOF
	done

	log "finished upgrading swift"
}

upgrade_cinder () {
	log "start upgrading cinder"

	cat <<-EOF | batchssh root@$(ask_packstack CONFIG_CINDER_HOST) bash
	openstack-service stop cinder
	yum -d1 -y upgrade openstack-cinder\* python-cinder python-cinderclient python-keystoneclient
	cinder-manage db sync
	openstack-service start cinder
	EOF

	log "finished upgrading cinder"
}

upgrade_glance () {
	log "start upgrading glance"

	cat <<-EOF | batchssh root@$(ask_packstack CONFIG_GLANCE_HOST) bash
	openstack-service stop glance
	yum -d1 -y upgrade openstack-glance\* python-glance python-glanceclient \
		python-keystoneclient python-cinderclient python-migrate
	glance-manage db_sync
	openstack-service start glance
	EOF

	log "finished upgrading glance"
}

upgrade_nova () {
	log "start upgrading nova"

	local hosts="$(ask_packstack CONFIG_NOVA_API_HOST) 
		$(ask_packstack CONFIG_NOVA_COMPUTE_HOSTS | tr ',' ' ')"

	for host in $hosts; do
		batchssh root@$host openstack-service stop nova
	done

	cat <<-EOF | batchssh root@$(ask_packstack CONFIG_NOVA_API_HOST) bash
	yum -d1 -y upgrade openstack-nova\* python-nova python-novaclient \
		python-keystoneclient python-migrate
	nova-manage db sync
	EOF

	for host in $(ask_packstack CONFIG_NOVA_COMPUTE_HOSTS | tr ',' ' '); do
		cat <<-EOF | batchssh root@$host bash
		yum -d1 -y upgrade openstack-nova\* python-nova python-novaclient \
			python-keystoneclient 
		EOF
	done

	for host in $hosts; do
		batchssh root@$host openstack-service start nova
	done

	log "finished upgrading nova"
}

quantum_db_preupgrade () {
	log "checking quantum database version"
	current_rev=$(batchssh root@$(ask_packstack CONFIG_QUANTUM_SERVER_HOST) \
		quantum-db-manage \
			--config-file /etc/quantum/quantum.conf \
			--config-file /etc/quantum/plugin.ini current 2>/dev/null |
		awk '/Current revision/ {print $NF}')

	if [ "$current_rev" = "None" ]; then
		log "adding grizzly version information to quantum database"
		batchssh root@$(ask_packstack CONFIG_QUANTUM_SERVER_HOST) \
			quantum-db-manage \
				--config-file /etc/quantum/quantum.conf \
				--config-file /etc/quantum/plugin.ini stamp grizzly
	fi
}

upgrade_neutron () {
	[ "$(ask_packstack CONFIG_QUANTUM_INSTALL)" = y ] || return

	quantum_db_preupgrade

	cat <<-EOF | batchssh root@$(ask_packstack CONFIG_QUANTUM_SERVER_HOST) bash
	openstack-service stop quantum
	openstack-service list quantum > /tmp/quantum-enabled-services
	yum -y -d1 upgrade openstack-quantum\* python-quantum python-quantumclient \
		python-keystoneclient
	EOF

	migrate_neutron_configs
}

######################################################################

PACKSTACK_ANSWERS=$1

if ! [ "$PACKSTACK_ANSWERS" ]; then
	echo "ERROR: You must specify an answers file" >&2
	exit 1
fi

if ! [ -f "$PACKSTACK_ANSWERS" ]; then
	echo "ERROR: answer file $PACKSTACK_ANSWERS does not exist." >&2
	exit 1
fi

######################################################################

# Verify connectivity before running upgrade process.

log "running pre-upgrade checks"

for svc in KEYSTONE GLANCE CINDER NOVA_API; do
	host=$(ask_packstack CONFIG_${svc}_HOST)
	case $svc in
		KEYSTONE) command="keystone-manage --help";;
		GLANCE) command="glance-manage --help";;
		CINDER) command="cinder-manage --help";;
		NOVA_API) command="nova-manage --help";;
		\*) command=true;;
	esac

	if ! batchssh root@$host $command > /dev/null; then
		die "failed to contact CONFIG_${svc}_HOST $host"
	fi
done

if [ "$(ask_packstack CONFIG_QUANTUM_INSTALL)" = y ]; then
	if ! batchssh root@$(ask_packstack CONFIG_QUANTUM_SERVER_HOST) true; then
		die "failed to contact CONFIG_QUANTUM_SERVER_HOST $host"
	fi
fi

######################################################################

workdir=$(mktemp -d /var/tmp/osupgradeXXXXXX)
trap 'rm -rf $workdir' EXIT

install_havana_repo
upgrade_keystone
upgrade_swift
upgrade_cinder
upgrade_glance
#upgrade_nova

log "upgrade complete"

