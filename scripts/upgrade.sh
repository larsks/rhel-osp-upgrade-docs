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
	for host in $all_hosts; do
		log "installing havana repository on $host"
		batchssh $host yum -d1 -y install \
			http://rdo.fedorapeople.org/openstack-havana/rdo-release-havana.rpm
	done
}

upgrade_keystone () {
	log "start upgrading keystone"

	cat <<-EOF | batchssh root@$keystone_host bash
	openstack-service stop keystone
	yum -d1 -y upgrade \*keystone\*
	keystone-manage db_sync
	openstack-service start keystone
	EOF

	# Make sure the client is upgraded everywhere.
	for host in $all_hosts; do
		batchssh root@$host "yum -y -d1 upgrade \*keystone\*"
	done

	log "finished upgrading keystone"
}

upgrade_swift () {
	log "start upgrading swift"

	for host in $swift_hosts; do
		cat <<-EOF | batchssh root@$host bash
		openstack-service stop swift
		yum -d1 -y upgrade \*swift\*
		openstack-service start swift
		EOF
	done

	# Make sure the client is upgraded everywhere.
	for host in $all_hosts; do
		batchssh root@$host "yum -y -d1 upgrade \*swift\*"
	done

	log "finished upgrading swift"
}

upgrade_cinder () {
	log "start upgrading cinder"

	cat <<-EOF | batchssh root@$cinder_host bash
	openstack-service stop cinder
	yum -d1 -y upgrade \*cinder\*
	cinder-manage db sync
	openstack-service start cinder
	EOF

	# Make sure the client is upgraded everywhere.
	for host in $all_hosts; do
		batchssh root@$host "yum -y -d1 upgrade \*cinder\*"
	done

	log "finished upgrading cinder"
}

upgrade_glance () {
	log "start upgrading glance"

	cat <<-EOF | batchssh root@$glance_host bash
	openstack-service stop glance
	yum -d1 -y upgrade \*glance\* python-migrate
	glance-manage db_sync
	openstack-service start glance
	EOF

	# Make sure the client is upgraded everywhere.
	for host in $all_hosts; do
		batchssh root@$host "yum -y -d1 upgrade \*glance\*"
	done

	# need to restart various nova services after glanceclient upgrade
	batchssh root@$nova_api_host openstack-service restart nova-api
	for host in $nova_compute_hosts; do
		batchssh root@$host openstack-service restart nova-compute
	done

	log "finished upgrading glance"
}

upgrade_nova () {
	log "start upgrading nova"

	for host in $nova_api_host $nova_compute_hosts; do
		cat <<-'EOF' | batchssh root@$host bash
		openstack-service stop nova
		yum -d1 -y upgrade \*nova\* python-migrate
		EOF
	done

	batchssh root@$nova_api_host nova-manage db sync

	for host in $nova_api_host $nova_compute_hosts; do
		batchssh root@$host openstack-service start nova
	done

	log "finished upgrading nova"
}

quantum_db_preupgrade () {
	log "checking quantum database version"
	network_db_rev=$(batchssh root@$(ask_packstack CONFIG_QUANTUM_SERVER_HOST) \
		quantum-db-manage \
			--config-file /etc/quantum/quantum.conf \
			--config-file /etc/quantum/plugin.ini current 2>/dev/null |
		awk '/Current revision/ {print $NF}')

	if [ "$network_db_rev" = "None" ]; then
		log "adding grizzly version information to quantum database"
		batchssh root@$(ask_packstack CONFIG_QUANTUM_SERVER_HOST) \
			quantum-db-manage \
				--config-file /etc/quantum/quantum.conf \
				--config-file /etc/quantum/plugin.ini stamp grizzly
	fi
}

upgrade_neutron () {
	if batchssh root@$network_host rpm -q --quiet openstack-neutron; then
		log "quantum->neutron upgrade has already happened (skipping)"
		return
	fi

	log "start quantum->neutron upgrade"

	quantum_db_preupgrade

	for host in $network_host $nova_compute_hosts; do
		log "upgrading quantum packages on $host"
		cat <<-'EOF' | batchssh root@$host bash
		openstack-service stop quantum
		openstack-service list quantum > /tmp/quantum-enabled-services
		userdel quantum
		yum -y -d1 upgrade \*quantum\*

		find /etc/quantum -name '*.rpmsave' | while read cf; do
			[ -f $cf ] || continue

			newcf=${cf/.rpmsave/}
			newcf=${newcf//quantum/neutron}
			sed '
				/^sql_connection/ b
				/^admin_user/ b
				s/quantum/neutron/g
				s/Quantum/Neutron/g
			' $cf > $newcf
		done

		if [ -h /etc/quantum/plugin.ini ]; then
			plugin_ini=$(readlink /etc/quantum/plugin.ini)
			ln -sf ${plugin_ini//quantum/neutron} /etc/neutron/plugin.ini
		fi

		sed s/quantum/neutron/ /tmp/quantum-enabled-services | 
			xargs -iSVC chkconfig SVC on
		EOF
	done

	# install python-neutronclient anywhere we find
	# python-quantumclient
	for host in $all_hosts; do
		cat <<-'EOF' | batch batchssh root@$host bash
		if rpm -q --quiet python-quantumclient; then
			yum -y -d1 install python-neutronclient
		fi
		EOF
	done

	cat <<-'EOF' | batchssh root@$network_host bash
	if [ -f /etc/neutron/plugin.ini ]; then
		neutron-db-manage \
			--config-file /etc/neutron/neutron.conf \
			--config-file /etc/neutron/plugin.ini upgrade head
	fi
	EOF

	for host in $network_host $nova_compute_hosts; do
		cat <<-'EOF' | batchssh root@$host bash
		openstack-service start neutron
		EOF
	done

	log "finished quantum->neutron upgrade"
}

upgrade_horizon () {
	log "start upgrade horizon"

	cat <<-'EOF' | batchssh root@$horizon_host root
	yum -y -d1 upgrade \*horizon\* \*openstack-dashboard\*
	service httpd restart
	EOF

	log "finished upgrade horizon"
}

upgrade_cleanup () {
	for host in $all_hosts; do
		log "start upgrade all packages on $host"
		batchssh root@$host yum -y -d1 upgrade
		log "finished upgrade all packages on $host"
	done

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

keystone_host=$(ask_packstack CONFIG_KEYSTONE_HOST)
glance_host=$(ask_packstack CONFIG_GLANCE_HOST)
cinder_host=$(ask_packstack CONFIG_CINDER_HOST)
nova_api_host=$(ask_packstack CONFIG_NOVA_API_HOST)
nova_compute_hosts=$(ask_packstack CONFIG_NOVA_COMPUTE_HOSTS|tr ',' ' ')
swift_hosts=$(ask_packstack CONFIG_SWIFT_STORAGE_HOSTS | tr , ' ')
horizon_host=$(ask_packstack CONFIG_HORIZON_HOST)

if [ "$(ask_packstack CONFIG_QUANTUM_INSTALL)" = y ]; then
	has_quantum=1
	network_host=$(ask_packstack CONFIG_QUANTUM_SERVER_HOST)
fi

all_hosts=$(
	cat <<-EOF | tr ' ' '\n' | sort -u
	$keystone_host
	$glance_host
	$cinder_host
	$network_host
	$nova_api_host
	$nova_compute_hosts
	$swift_hosts
	$horizon_host
	EOF
)

# Verify connectivity before running upgrade process.

log "running pre-upgrade checks"

for host in $all_hosts; do
	if ! batchssh root@$host true; then
		echo "ERROR: unable to contact host $host"
		exit 1
	fi
done

######################################################################

workdir=$(mktemp -d /var/tmp/osupgradeXXXXXX)
trap 'rm -rf $workdir' EXIT

install_havana_repo
upgrade_keystone
upgrade_swift
upgrade_cinder
upgrade_glance

[ "$has_quantum" = 1 ] && upgrade_neutron

upgrade_nova
upgrade_horizon
upgrade_cleanup

log "upgrade complete"

