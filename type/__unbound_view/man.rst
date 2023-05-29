cdist-type__unbound_view(7)
===========================

NAME
----
cdist-type__unbound_view - Manage unbound views


DESCRIPTION
-----------
This type can be used to manage unbound views.


REQUIRED PARAMETERS
-------------------
None.


OPTIONAL PARAMETERS
-------------------
local-data
   ...

   The value will be quoted automatically.

   Can be used multiple times.
local-data-ptr
   ...

   The value will be quoted automatically.

   Can be used multiple times.
local-zone
   ...

   The values needs to be quoted according to the :strong:`unbound.conf`\ (5)
   file format.

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

   #
   __unbound_view intra \


SEE ALSO
--------
* :strong:`cdist-type__unbound_server`\ (7)
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
