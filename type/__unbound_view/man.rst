cdist-type__unbound_view(7)
===========================

NAME
----
cdist-type__unbound_view - Manage unbound views


DESCRIPTION
-----------
This type can be used to manage unbound views.


OPTIONAL PARAMETERS
-------------------
local-data
   ``name type value``, e.g. ``example.com. A 127.0.0.1``

   Configure a local DNS RR entry which is served in response to queries for it.

   The query has to match exactly; if it does not match exactly the type of the
   zone this RR is within determines how the query is further processed, cf.
   ``--local-zone``.

   The value will be quoted automatically.

   Can be used multiple times.
local-data-ptr
   ``ipaddr name``, e.g. ``192.0.2.4 www.example.com``

   Syntactic sugar for ``--local-data`` to conveniently configure ``PTR`` RRs.

   The value will be quoted automatically.

   Can be used multiple times.
local-zone
   ``"zone" type``

   Configure a local zone. The type determines the answer which is given to
   queries for which there is no match from ``--local-data``.

   The name of the zone must be quoted in double quotes.

   For more information on the types available, cf. :strong:`unbound.conf`\ (5).

   Can be used multiple times.
state
   One of:

   ``present``
      the view exists
   ``absent``
      the view does not exist

   Defaults to: ``present``


BOOLEAN PARAMETERS
------------------
view-first
   Attempt to use the global ``local-zone:`` and ``local-data:`` if there is no
   match in the view specific options.


EXAMPLES
--------

.. code-block:: sh

   # configure a view with some local RRs (simple split-horizon DNS)
   __unbound_view intra \
      --local-zone '"example.com" transparent' \
      --local-data 'example.com. A 172.16.0.100' \
      --local-data 'www.example.com. A 172.16.0.100' \
      --local-data 'mail.example.com. A 172.16.0.110' \
      --local-data-ptr '172.16.0.100 www.example.com' \
      --local-data-ptr '172.16.0.110 mail.example.com' \
      --view-first


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
