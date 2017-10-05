######################################################
Setting up a SOCKS Proxy using SSH on a cloud instance
######################################################

A generic HTTP proxy can be created using a Catalyst Cloud instance. This proxy
utilises the native SOCKS5 support in OpenSSH.

****************************
Establishing the SOCKS proxy
****************************

On Linux
========

In a terminal, connect to your instance using SSH with dynamic port forwarding
enabled::

  ssh -D 6676 tunnel@[ip]

You should leave this SSH session established while using the proxy.

Now, your browser needs to be configured to use this tunnel as a proxy. The
procedure varies per browser and is described below for Firefox and Chrome.

Firefox
-------

In your browser, change its proxy settings (under Preferences, Advanced,
Network, Settings) to use the cloud-tunnel as a SOCKS proxy, as per the example
below:

.. image:: ../_static/ct-firefox-proxy.png
   :align: center

Chrome
------

In your browser, enter the URL chrome://settings/search#proxy and click on the
“Change proxy settings...” button. This should open your system network
settings, where you should change the Socks Host (under Network proxy) as
indicated below:

.. image:: ../_static/ct-chrome-proxy.png
   :align: center

On Mac
======

In a terminal, connect to your instance using SSH with dynamic port forwarding
enabled::

  ssh -D 6676 tunnel@[ip]

You should leave this SSH session established while using the proxy. Now,
your browser needs to be configured to use this tunnel as a proxy. The
procedure varies per browser and is described below for Safari, Chrome and
Firefox.

Safari
------

In your network settings (under system settings), change your proxy settings to
use the cloud-tunnel as a SOCKS proxy, as per the example below:

.. image:: ../_static/ct-safari-proxy.png
   :align: center

Chrome
------

In your browser, enter the URL chrome://settings/search#proxy and click on the
“Change proxy settings...” button. This should open your system network
settings, where you should change the Socks Proxy (under Proxies) as indicated
on the previous Safari example.

Firefox
-------

In your browser, change its proxy settings (under Preferences, Advanced,
Network, Settings) to use the cloud-tunnel as a SOCKS proxy, as per the example
below:

.. image:: ../_static/ct-firefox-proxy.png
   :align: center

On Windows
==========

In order to establish a SSH connection with your cloud tunnel you will need an
SSH client. If you do not have one, you can download and install PuTTY from:
http://the.earth.li/~sgtatham/putty/latest/x86/putty-0.63-installer.exe

After installing PuTTY, open it and connect to your cloud tunnel instance. On
the Category list, go to Connection, SSH and Tunnels. For the destination
source port, enter 6676 and select Dynamic and then click on “Add”, as
indicated on the image below.

.. image:: ../_static/ct-putty-pf-config.png
   :align: center

On the Category list, go back to session and enter the IP address of your cloud
tunnel instance.

.. image:: ../_static/ct-putty-connect.png
   :align: center

You should leave this SSH session established while using the proxy.

Now, your browser needs to be configured to use this tunnel as a proxy. The
procedure varies per browser and is described below for Internet Explorer,
Chrome and Firefox.

Internet Explorer
-----------------

On the configuration menu, open “Internet options”.

.. image:: ../_static/ct-ie-proxy01.png
   :align: center

On the connections tab open your “LAN settings” and click on “Advanced”.

.. image:: ../_static/ct-ie-proxy02.png
   :align: center

On the proxy settings screen, configure the socks proxy with your local host
(127.0.0.1) and the port used for the SSH tunnel (6676) as indicated below:

.. image:: ../_static/ct-ie-proxy03.png
   :align: center

Chrome
------

In your browser, enter the URL chrome://settings/search#proxy and click on the
“Change proxy settings...” button. This should open your system internet
options, where you can configure a SOCKS proxy as explained previously
in the Internet Explorer example.

Firefox
-------

In your browser, change its proxy settings (under Options, Advanced, Network,
Settings) to use the cloud-tunnel as a SOCKS proxy, as per the example below:

.. image:: ../_static/ct-firefox-proxy.png
   :align: center


**********************************
Using the proxy with other clients
**********************************

Many HTTP clients offer support for SOCKS proxying. Please consult the
documentation for your library.

OpenStack Clients
=================

Most OpenStack command line clients use the urllib3 library. SOCKS5 support is
offered via the `urllib3.contrib.socks`_ module.

.. _urllib3.contrib.socks: https://urllib3.readthedocs.org/en/latest/contrib.html#socks

cURL
====

CURL supports SOCKS5 proxying natively. It is available via the ``--proxy``,
``--socks5`` or ``--socks5-hostname`` options.
