Python Client for the URN PID service by the National Library of Norway
=======================================================================


Library
-------
The **lib** directory contains the library for communicating with the SOAP API.


Command Line Tools
------------------

The **bin** directory contains a set of command line tools that make use of the library.

### Examples for command line tools:
`./bin/find_urn --urn URN:NBN:no-27984`
`./bin/find_urns_for_url --url https://www.duo.uio.no/handle/10852/18033`

Configuration
-------------

The **config** directory contains an example of the YAML config file used by the client.
Replace the dummy entries with the information you have received from the National Library and put it in a `config.yml` file in the same directory.


Dependencies
------------

* SOAP::Lite

Recommendation: Create a virtualenv and install these dependencies using pip.

