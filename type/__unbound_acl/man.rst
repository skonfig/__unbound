cdist-type__unbound_acl(7)
===========================

NAME
----
cdist-type__unbound_acl - Manage unbound access-control directives


DESCRIPTION
-----------
This type can be used to manage unbound ``access-control`` configuration options.


REQUIRED PARAMETERS
-------------------
None.


OPTIONAL PARAMETERS
-------------------
action
   The action to take for request from one of the ``--netblock``s.

   cf. :strong:`unbound.conf`\ (5) on ``access-control:`` for acceptable values.
netblock
   Apply options of this type to requests from the specified netblock.

   Can be used multiple times.
state
   One of:

   ``present``
      the ACL config exists
   ``absent``
      the ACL config does not exist

   Defaults to: ``present``
tag
   Attach a tag to requests from one of the ``--netblocks``.

   Can be used multiple times.
view
   Use a view (cf. :strong:`cdist-type__unbound_view`\ (7)) for requests from
   one of the ``--netblocks``


BOOLEAN PARAMETERS
------------------
None.


EXAMPLES
--------

.. code-block:: sh

   # Tag requests from the 10/8 subnet
   __unbound_acl internal-requests \
      --netblock 10.0.0.0/8 \
      --action allow \
      --tag internal


SEE ALSO
--------
* :strong:`cdist-type__unbound_server`\ (7)
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
