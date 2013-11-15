- openstack-glance needs a versioned Requires: on python-migrate >=
  0.7.2 to avoid:
  
      2013-11-07 20:16:32.073 17011 CRITICAL glance [-] 'module' object has no attribute 'DatabaseAlreadyControlledError'

- after glance upgrade, grizzly nova appears to be unable to talk to
  havana glance:

      2013-11-07 20:27:28.717 11665 TRACE nova.api.openstack   File "/usr/lib/python2.6/site-packages/glanceclient/common/http.py", line 51, in <module>
      2013-11-07 20:27:28.717 11665 TRACE nova.api.openstack     GreenSocket.getsockopt = utils.getsockopt
      2013-11-07 20:27:28.717 11665 TRACE nova.api.openstack AttributeError: 'module' object has no attribute 'getsockopt'


- something (openstack-dashboard? django?) needs dependency on
  python-pbr, otherwise you get this:

>>> import openstack_dashboard.settings
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "openstack_dashboard/settings.py", line 28, in <module>
    from openstack_dashboard import exceptions
  File "openstack_dashboard/exceptions.py", line 23, in <module>
    from heatclient import exc as heatclient
  File "/usr/lib/python2.7/site-packages/heatclient/__init__.py", line 13, in <module>
    import pbr.version
ImportError: No module named pbr.version

Which manifests in error_log as:

[Sat Nov 09 21:46:05.382168 2013] [:error] [pid 20998] [remote 192.168.122.1:21571]     raise
 ImportError("Could not import settings '%s' (Is it on sys.path?): %s" % (self.SETTINGS_MODUL
E, e))


