cdist-type__unbound_auth_zone(7)
================================

NAME
----
cdist-type__unbound_auth_zone - Manage unbound auth-zones


DESCRIPTION
-----------
This type can be used to manage unbound auth-zones.


OPTIONAL PARAMETERS
-------------------
allow-notify
   Specify an additional source for notifies.

   Can be used multiple times.
primary
   Specify a primary NS to download a copy of the zone from, with AXFR and IXFR.

   Can be used multiple times. All primaries are tried if one fails.
state
   One of:

   ``present``
      the auth-zone exists
   ``absent``
      the auth-zone does not exist

   Defaults to: ``present``
url
   Specify an URL to download a zonefile for the zone from (using HTTP/HTTPS).

   Can be used multiple times. The URLs will be tried in turn.


BOOLEAN PARAMETERS
------------------
check-zonemd
   Check ``ZONEMD`` records in this zone.
enable-fallback
   Tell Unbound to fall back to querying the internet as a resolver for this
   zone when lookups fail.  For example for DNSSEC validation failures.
not-for-downstream
   By default, Unbound serves authority responses to downstream clients for this
   zone and makes Unbound behave, for the queries with names in this zone, like
   one of the authority servers for that zone.

   Use this parameter if you want Unbound to provide recursion for the zone but
   have a local copy of zone data.
not-for-upstream
   By default, Unbound fetches data from this data collection for answering
   recursion queries. Instead of sending queries over the internet to the
   authority servers for this zone, it'll fetch the data directly from the zone
   data.

   Use this parameter if you don't want Unbound to use the zone data as a local
   copy to speed up lookups.
zonemd-reject-absence
   Reject the zone if the ``ZONEMD`` record is absent.
   Without this option, when ``ZONEMD`` is not there it is not checked.


EXAMPLES
--------

.. code-block:: sh

   # fetch auth zone example.net from URL
   __unbound_auth_zone example.net \
      --url 'http://192.0.2.1/unbound-primaries/example.com.zone'


SEE ALSO
--------
* :strong:`cdist-type__unbound_server`\ (7)
* :strong:`unbound`\ (8)
* :strong:`unbound.conf`\ (5)


AUTHORS
-------
* Dennis Camera <dennis.camera--@--riiengineering.ch>


COPYING
-------
Copyright \(C) 2023 Dennis Camera.
You can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.
