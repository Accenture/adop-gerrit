#Supported tags and respective Dockerfile links

- [`0.0.10`, `0.0.10` (*0.0.10/Dockerfile*)](https://innersource.accenture.com/adop/docker-gerrit/source/51a674d192a10dedee5a3330af2cd20d40741754:Dockerfile)

# What is docker-gerrit?

docker-gerrit is a wrapper for the openfrontier/gerrit image. It has primarily been built to perform extended configuration.
Gerrit, web-based collaboration tool. Gerrit aims to facilitate reviews of source code in the context of a software developers in a team.

# How to use this image

The easiest for to run docker-gerrit image is as follow:
```
docker run --name <your-container-name> -d -p 8080:8080 -p 29418:29418 docker.accenture.com/adop/docker-gerrit:VERSION
```
after the above gerrit will be available at: http://localhost:8080

## Run docker-gerrit with MySQL and OpenLDAP
The following assumes that MySQL and OpenLDAP are running.

The following command will run docker-gerrit and connect it to MySQL and OpenLDAP
```
  docker run \
  --name adop-gerrit \
  -p 8080:8080 \
  -p 29418:29418 \
  -e DATABASE_TYPE=mysql \
  -e DB_HOSTNAME=<mysql-servername> 
  -e DB_PORT="3306"
  -e DB_NAME=<mysql-dbame>
  -e DB_USER=<mysql-dbuser>
  -e DB_PASSWORD=<mysql-dbpassword>
  -e AUTH_TYPE=LDAP \
  -e LDAP_SERVER=<ldap-servername:389> \
  -e LDAP_ACCOUNTBASE=<ldap-basedn> \
  -d docker.accenture.com/adop/docker-gerrit:VERSION
```

In addition all the LDAP attibutes defined in [Gerrid LDAP](https://gerrit-review.googlesource.com/Documentation/config-gerrit.html#ldap) are supported.

# License
Please view [licence information](LICENCE.md) for the software contained on this image.

#Supported Docker versions

This image is officially supported on Docker version 1.9.1.
Support for older versions (down to 1.6) is provided on a best-effort basis.

# User feedback

## Documentation
Documentation for this image is available in the [Gerrit documenation page](https://gerrit-review.googlesource.com/Documentation/config-gerrit.html). 
Additional documentaion can be found under the [`docker-library/docs` GitHub repo](https://github.com/docker-library/docs). Be sure to familiarize yourself with the [repository's `README.md` file](https://github.com/docker-library/docs/blob/master/README.md) before attempting a pull request.

## Issues
If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/Accenture/adop-gerrit/issues).

## Contribute
You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/Accenture/adop-gerrit/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
