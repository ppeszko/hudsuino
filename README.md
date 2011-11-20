Hudsuino/Jenkinsino
===================

Sketch for pulling build status from Hudson/Jenkins and displaying it with LEDs (or traffic lights :)

LEDs
-----

* green/red LED - build status
* yellow LED - pulling new build status

Setup
-----

Point HUDSON_SERVER and HUDSON_PORT to your hudson/jenkins instance. With POLLING_INTERVAL you can specify delays between checking build status.

After that just upload the sketch to your arduino (arduino shield needed) and have fun!

Author
------

Patryk Peszko
