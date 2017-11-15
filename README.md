This is a helper to run a concourse-ci server right of the box, by generating the private keys right away.

It is used e.g. here https://github.com/EugenMayer/docker-rancher-extra-catalogs/tree/master/templates but can used in any docker-compose.yml

You can see the `example/docker-compose.yml` and start a full functional server using

    cd example
    docker-compose up
    
Now you can login using concourse/changeme on `http://loclhost:8080`     

