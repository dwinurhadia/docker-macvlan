# Documentation
> Make sure you already download docker, docker-compose  and git

This repository for docker wordpress with php ldap module, mysql, phpmyadmin and redis cache. Also wordpress using 2 network bridge to communicate with other container same network in docker compose and macvlan to communicate outside network with dedicate ip address.

Here is network diagram for the container schema

![Topology](https://i.ibb.co/C8PFCdG/Topology.png)

## Step to Run

Download repository and enter working directory

    git clone https://github.com/dwinurhadia/macvlan.git
    cd macvlan

> please make sure you don't have same exposing port in same docker host and also ip address available

Make 2 folder for db and wordpress document

    mkdir db_data wordpress_data
    chmod -R 777 db_data

Build Dockerfile to image

    docker-compose build

Running Docker Compose

    docker-compose up -d
Wait for a few min then open your ip address wordpress container in browser

    ex: http://10.55.254.33:80
    
To open phpmyadmin, please open docker host ip and port expose by phpmyadmin

    ex: http://10.55.254.126:8011
