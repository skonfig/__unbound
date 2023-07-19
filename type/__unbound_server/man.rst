cdist-type__unbound_server(7)
=============================

NAME
----
cdist-type__unbound_server - Install and manage server configuration of an
unbound DNS resolver


DESCRIPTION
-----------

This type can be used to install the unbound DNS resolver and manage its server
configuration (in ``/etc/unbound/unbound.conf`` that is).

Distribution default values will be kept in the config file, unless a parameter
to this type explicitly overwrites the value to something else.
Also note that removing a singleton optional parameter later on will not restore
the distribution default, but simply leave the config as it is.
Removing a multiple optional parameter will remove that value from the config.


REQUIRED PARAMETERS
-------------------
None.


OPTIONAL PARAMETERS
-------------------
access-control
   Specifies a net block for access control to the unbound resolver:
   ``<IP netblock> <action>``

   For more information, please refer to :strong:`unbound.conf`\ (5).

   This parameter can be used multiple times.
access-control-view
   Set view for given access control element.
cache-max-ttl
   Maximum time to live (TTL) for RRsets and messages in the cache.

   Can be lowered to force the resolver to query for data more often, and not
   trust (very large) TTL values.
cache-max-negative-ttl
   Maximum time to live for negative responses.
   This applies to ``NXDOMAIN`` and ``NODATA`` answers.
cache-min-ttl
   Minimum time to live (TTL) for RRsets and messages in the cache.

   If the minimum kicks in, the data is cached for longer than the domain owner
   intended, and thus less queries are made to look up the data.

   Zero makes sure the data in the cache is as the domain owner intended.
interface
   Specifies an interface for unbound to listen on:
   ``<ip or iface>[@port]``

   Can be used multiple times listen on more than one interface.
logfile
   Specifies the file to which unbound should send log messages.
   The file needs to pre-exist with the correct permissions.

   If not set, logging goes to syslog.
msg-cache-size
   Size of the message cache.

   A plain number is in bytes, append ``k``, ``m`` or ``g`` for kibiobytes,
   mebibytes or gibibytes (base 2).
num-threads
   The number of threads to create to serve clients.
   Use ``1`` for no threading.

   Defaults to: number of CPU cores on target.
outgoing-interface
   Interface to use to connect to the network. This interface is used to send
   queries to authoritative servers and receive their replies. Can be given
   multiple times to work on several interfaces.
port
   The port unbound should answer queries on.
private-domain
   Specify a domain (and all of its subdomains) which is allowed to contain private addresses.

   Can be used multiple times.
qname-minimisation
   Specifies whether to enable QNAME minimisation.

   cf. `<https://www.rfc-editor.org/rfc/rfc7816.txt>`_

   Value must be one of:

   yes
      enable QNAME minimisation, but be gentle with broken name servers.
   strict
      enable QNAME minimisation without fallback for broken name servers.
	  cf. :strong:`unbound.conf`\ (5) for `qname-minimisation-strict` option.
   no
      disable QNAME minimisation

   Defaults to: ``yes``
rc-interface
   An interface for NSD to listen on for remote control:
   ``<ip4 or ip6 or filename>``

   Can be used multiple times to bind on multiple interfaces.

   If an absolute path is used, a UNIX local named pipe is created (and key and
   cert files are not needed, use directory permissions).
rc-port
   The port number the remote control service should listen on.
rrset-cache-size
   Size of the RRset cache.

   A plain number is in bytes, append ``k``, ``m`` or ``g`` for kibiobytes,
   mebibytes or gibibytes (base 2).
state
   One of:

   ``present``
      unbound is installed
   ``absent``
      unbound is not installed

   Defaults to: ``present``


BOOLEAN PARAMETERS
------------------
interface-automatic
   Listen on all addresses on all (current and future) interfaces, detect the
   source interface on UDP queries and copy them to replies.

   This feature is experimental, and needs support in your OS for particular
   socket options.
hide-identity
   Configure unbound to not answer ``id.server`` and ``hostname.bind`` queries.
hide-version
   Configure unbound to not answer ``VERSION.BIND`` and ``VERSION.SERVER``
   ``CHAOS`` class queries.
no-ipv4
   Do not listen on IPv4 port.
no-ipv6
   Do not listen on IPv6 port.
no-remote-control
   Disable remote control with :strong:`unbound-control`\ (8) completely.

   **NB:** Enabling this option will break the other :strong:`__unbound_*`
   types.


EXAMPLES
--------

.. code-block:: sh

   # Install an unbound DNS resolver with default settings
   __unbound_server


BUGS
----
This type assumes that the main server config is located at
``/etc/unbound/unbound.conf`` on the target.
Furthermore, a sanely formatted `unbound.conf` file is assumed, i.e. only one
configuration option on a single line.


SEE ALSO
--------
* :strong:`cdist-type__unbound_view`\ (7)
* :strong:`unbound`\ (8)
* :strong:`unbound.conf`\ (5)


AUTHORS
-------
Dennis Camera <dennis.camera--@--riiengineering.ch>


COPYING
-------
Copyright \(C) 2023 Dennis Camera.
You can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.
