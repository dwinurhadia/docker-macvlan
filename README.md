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

## Custom php module

To add custom php config just put your config .ini in `php_custom` folder

> Need attention!

### Issue 1

If we define same name in macvlan network docker-compose

    ERROR: Network "dockervlan" needs to be recreated - option "parent" has changed

To fix this, you need change different name of `network name`

### Issue 2

If we have multiple docker-compose file running on same docker-host. Make sure new docker-compose is getting in `different ip pool network`. In example you define `10.55.254.200/32` it will make another docker-compose file cannot access internet or getting some error when start

    root@881b220c6ced:/var/www/html# ip a | grep inet
        inet 127.0.0.1/8 scope host lo
        inet 192.168.16.5/20 brd 192.168.31.255 scope global eth1
        inet 10.55.208.201/24 brd 10.55.208.255 scope global eth0
    root@881b220c6ced:/var/www/html# ping google.com
    PING google.com (172.217.194.100) 56(84) bytes of data.
    From 881b220c6ced (10.55.208.201) icmp_seq=1 Destination Host Unreachable
    From 881b220c6ced (10.55.208.201) icmp_seq=2 Destination Host Unreachable
    From 881b220c6ced (10.55.208.201) icmp_seq=3 Destination Host Unreachable
    ^C
    --- google.com ping statistics ---
    5 packets transmitted, 0 received, +3 errors, 100% packet loss, time 4090ms
    pipe 4
    root@881b220c6ced:/var/www/html#

You need to increase `ip_range` pool to make sure multiple container join in same network. 

### Issue 3

You can ignore if you shutdown docker-compose file still getting error warning

    d@nginx:~/$ docker-compose down
    Stopping pma       ... done
    Stopping wordpress ... done
    Stopping mysql     ... done
    Stopping redis     ... done
    Removing pma       ... done
    Removing wordpress ... done
    Removing mysql     ... done
    Removing redis     ... done
    Removing network wp_backend
    Removing network dockervlan
    ERROR: error while removing network: network dockervlan id 122371046f4ad87edcd7f445fd6cdc0c67c2cbe11556e6b99c3c1a774387bf8c has active endpoints

This happen because another docker-compose join with same macvlan network

### Issue 4

Same network macvlan and same ip_range

    d@nginx:~/wp-208-1$ docker-compose up -d
    Creating network "wp-208-1_backend" with driver "bridge"
    Creating network "vlan208" with driver "macvlan"
    ERROR: Pool overlaps with other one on this address space

The error you are encountering is suggesting you have a network address conflict. To check that you could run: `docker network ls` to list all the docker network running currently on your machine.
Please change `ip_range` to different pool

### Issue 5

Multiple network macvlan in same network and different pool will getting an error

    d@nginx:~/test2$ docker-compose up -d
    Creating network "dockervlan1" with driver "macvlan"
    ERROR: failed to allocate gateway (10.55.212.1): Address already in use
    d@nginx:~/test2$


## Solution

### Case 1

If we have multiple container with same network macvlan, make sure you `have same network macvlan, and different subnet ip_range`

Container 1

    networks:
      backend:
        driver : bridge
    
      dockervlan:
        name: dockervlan
        driver: macvlan
        driver_opts:
          parent: eth1
        ipam:
          config:
            - subnet: "10.55.212.0/24"
              ip_range: "10.55.212.8/29" 
              gateway: "10.55.212.1" 

Container 2

    networks:
      backend:
        driver : bridge
    
      dockervlan:
        name: dockervlan
        driver: macvlan
        driver_opts:
          parent: eth1
        ipam:
          config:
            - subnet: "10.55.212.0/24" 
              ip_range: "10.55.212.16/29"
              gateway: "10.55.212.1" 


### Case 2

You must add multiple interface or vlan to add multiple network macvlan in same dockerhost
List interface

    d@nginx:~/$ ifconfig | grep eth
    eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
            ether 00:15:5d:01:b6:27  txqueuelen 1000  (Ethernet)
    eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
            ether 00:15:5d:01:b6:33  txqueuelen 1000  (Ethernet)
    eth2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500

List Network

    d@nginx:~/$ docker network ls
    NETWORK ID     NAME            DRIVER    SCOPE
    53ee875c1cc6   bridge          bridge    local
    dde4b07c021e   dockervlan      macvlan   local
    a4ca9d50367a   dockervlan1     macvlan   local
    a96a4a09b05b   host            host      local
    674e18cf6f16   none            null      local
    d@nginx:~/$

Here is mapping for the interface in same dockerhost

[![](https://mermaid.ink/img/eyJjb2RlIjoiXG5ncmFwaCBMUlxuQVtEb2NrZXIgSG9zdF0gLS0-IEJbRXRoMF1cbkEgLS0-IENbRXRoMV1cbkEgLS0-IERbRXRoMl1cbkIgLS0-IEVbYnJpZGdlXVxuQyAtLSBtYWN2bGFuIC0tPiBGW2RvY2tlcnZsYW5dXG5EIC0tIG1hY3ZsYW4gLS0-IEdbZG9ja2VydmxhbjFdXG5GIC0tPiBIW2NvbnRhaW5lcjFdXG5GIC0tPiBJW2NvbnRhaW5lcjJdXG5HIC0tPiBKW2NvbnRhaW5lcjNdXG5HIC0tPiBLW2NvbnRhaW5lcjRdXG4iLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCIsInRoZW1lVmFyaWFibGVzIjp7ImJhY2tncm91bmQiOiJ3aGl0ZSIsInByaW1hcnlDb2xvciI6IiNFQ0VDRkYiLCJzZWNvbmRhcnlDb2xvciI6IiNmZmZmZGUiLCJ0ZXJ0aWFyeUNvbG9yIjoiaHNsKDgwLCAxMDAlLCA5Ni4yNzQ1MDk4MDM5JSkiLCJwcmltYXJ5Qm9yZGVyQ29sb3IiOiJoc2woMjQwLCA2MCUsIDg2LjI3NDUwOTgwMzklKSIsInNlY29uZGFyeUJvcmRlckNvbG9yIjoiaHNsKDYwLCA2MCUsIDgzLjUyOTQxMTc2NDclKSIsInRlcnRpYXJ5Qm9yZGVyQ29sb3IiOiJoc2woODAsIDYwJSwgODYuMjc0NTA5ODAzOSUpIiwicHJpbWFyeVRleHRDb2xvciI6IiMxMzEzMDAiLCJzZWNvbmRhcnlUZXh0Q29sb3IiOiIjMDAwMDIxIiwidGVydGlhcnlUZXh0Q29sb3IiOiJyZ2IoOS41MDAwMDAwMDAxLCA5LjUwMDAwMDAwMDEsIDkuNTAwMDAwMDAwMSkiLCJsaW5lQ29sb3IiOiIjMzMzMzMzIiwidGV4dENvbG9yIjoiIzMzMyIsIm1haW5Ca2ciOiIjRUNFQ0ZGIiwic2Vjb25kQmtnIjoiI2ZmZmZkZSIsImJvcmRlcjEiOiIjOTM3MERCIiwiYm9yZGVyMiI6IiNhYWFhMzMiLCJhcnJvd2hlYWRDb2xvciI6IiMzMzMzMzMiLCJmb250RmFtaWx5IjoiXCJ0cmVidWNoZXQgbXNcIiwgdmVyZGFuYSwgYXJpYWwiLCJmb250U2l6ZSI6IjE2cHgiLCJsYWJlbEJhY2tncm91bmQiOiIjZThlOGU4Iiwibm9kZUJrZyI6IiNFQ0VDRkYiLCJub2RlQm9yZGVyIjoiIzkzNzBEQiIsImNsdXN0ZXJCa2ciOiIjZmZmZmRlIiwiY2x1c3RlckJvcmRlciI6IiNhYWFhMzMiLCJkZWZhdWx0TGlua0NvbG9yIjoiIzMzMzMzMyIsInRpdGxlQ29sb3IiOiIjMzMzIiwiZWRnZUxhYmVsQmFja2dyb3VuZCI6IiNlOGU4ZTgiLCJhY3RvckJvcmRlciI6ImhzbCgyNTkuNjI2MTY4MjI0MywgNTkuNzc2NTM2MzEyOCUsIDg3LjkwMTk2MDc4NDMlKSIsImFjdG9yQmtnIjoiI0VDRUNGRiIsImFjdG9yVGV4dENvbG9yIjoiYmxhY2siLCJhY3RvckxpbmVDb2xvciI6ImdyZXkiLCJzaWduYWxDb2xvciI6IiMzMzMiLCJzaWduYWxUZXh0Q29sb3IiOiIjMzMzIiwibGFiZWxCb3hCa2dDb2xvciI6IiNFQ0VDRkYiLCJsYWJlbEJveEJvcmRlckNvbG9yIjoiaHNsKDI1OS42MjYxNjgyMjQzLCA1OS43NzY1MzYzMTI4JSwgODcuOTAxOTYwNzg0MyUpIiwibGFiZWxUZXh0Q29sb3IiOiJibGFjayIsImxvb3BUZXh0Q29sb3IiOiJibGFjayIsIm5vdGVCb3JkZXJDb2xvciI6IiNhYWFhMzMiLCJub3RlQmtnQ29sb3IiOiIjZmZmNWFkIiwibm90ZVRleHRDb2xvciI6ImJsYWNrIiwiYWN0aXZhdGlvbkJvcmRlckNvbG9yIjoiIzY2NiIsImFjdGl2YXRpb25Ca2dDb2xvciI6IiNmNGY0ZjQiLCJzZXF1ZW5jZU51bWJlckNvbG9yIjoid2hpdGUiLCJzZWN0aW9uQmtnQ29sb3IiOiJyZ2JhKDEwMiwgMTAyLCAyNTUsIDAuNDkpIiwiYWx0U2VjdGlvbkJrZ0NvbG9yIjoid2hpdGUiLCJzZWN0aW9uQmtnQ29sb3IyIjoiI2ZmZjQwMCIsInRhc2tCb3JkZXJDb2xvciI6IiM1MzRmYmMiLCJ0YXNrQmtnQ29sb3IiOiIjOGE5MGRkIiwidGFza1RleHRMaWdodENvbG9yIjoid2hpdGUiLCJ0YXNrVGV4dENvbG9yIjoid2hpdGUiLCJ0YXNrVGV4dERhcmtDb2xvciI6ImJsYWNrIiwidGFza1RleHRPdXRzaWRlQ29sb3IiOiJibGFjayIsInRhc2tUZXh0Q2xpY2thYmxlQ29sb3IiOiIjMDAzMTYzIiwiYWN0aXZlVGFza0JvcmRlckNvbG9yIjoiIzUzNGZiYyIsImFjdGl2ZVRhc2tCa2dDb2xvciI6IiNiZmM3ZmYiLCJncmlkQ29sb3IiOiJsaWdodGdyZXkiLCJkb25lVGFza0JrZ0NvbG9yIjoibGlnaHRncmV5IiwiZG9uZVRhc2tCb3JkZXJDb2xvciI6ImdyZXkiLCJjcml0Qm9yZGVyQ29sb3IiOiIjZmY4ODg4IiwiY3JpdEJrZ0NvbG9yIjoicmVkIiwidG9kYXlMaW5lQ29sb3IiOiJyZWQiLCJsYWJlbENvbG9yIjoiYmxhY2siLCJlcnJvckJrZ0NvbG9yIjoiIzU1MjIyMiIsImVycm9yVGV4dENvbG9yIjoiIzU1MjIyMiIsImNsYXNzVGV4dCI6IiMxMzEzMDAiLCJmaWxsVHlwZTAiOiIjRUNFQ0ZGIiwiZmlsbFR5cGUxIjoiI2ZmZmZkZSIsImZpbGxUeXBlMiI6ImhzbCgzMDQsIDEwMCUsIDk2LjI3NDUwOTgwMzklKSIsImZpbGxUeXBlMyI6ImhzbCgxMjQsIDEwMCUsIDkzLjUyOTQxMTc2NDclKSIsImZpbGxUeXBlNCI6ImhzbCgxNzYsIDEwMCUsIDk2LjI3NDUwOTgwMzklKSIsImZpbGxUeXBlNSI6ImhzbCgtNCwgMTAwJSwgOTMuNTI5NDExNzY0NyUpIiwiZmlsbFR5cGU2IjoiaHNsKDgsIDEwMCUsIDk2LjI3NDUwOTgwMzklKSIsImZpbGxUeXBlNyI6ImhzbCgxODgsIDEwMCUsIDkzLjUyOTQxMTc2NDclKSJ9fSwidXBkYXRlRWRpdG9yIjpmYWxzZSwiYXV0b1N5bmMiOnRydWUsInVwZGF0ZURpYWdyYW0iOmZhbHNlfQ)](https://mermaid-js.github.io/mermaid-live-editor/edit#eyJjb2RlIjoiXG5ncmFwaCBMUlxuQVtEb2NrZXIgSG9zdF0gLS0-IEJbRXRoMF1cbkEgLS0-IENbRXRoMV1cbkEgLS0-IERbRXRoMl1cbkIgLS0-IEVbYnJpZGdlXVxuQyAtLSBtYWN2bGFuIC0tPiBGW2RvY2tlcnZsYW5dXG5EIC0tIG1hY3ZsYW4gLS0-IEdbZG9ja2VydmxhbjFdXG5GIC0tPiBIW2NvbnRhaW5lcjFdXG5GIC0tPiBJW2NvbnRhaW5lcjJdXG5HIC0tPiBKW2NvbnRhaW5lcjNdXG5HIC0tPiBLW2NvbnRhaW5lcjRdXG4iLCJtZXJtYWlkIjoie1xuICBcInRoZW1lXCI6IFwiZGVmYXVsdFwiLFxuICBcInRoZW1lVmFyaWFibGVzXCI6IHtcbiAgICBcImJhY2tncm91bmRcIjogXCJ3aGl0ZVwiLFxuICAgIFwicHJpbWFyeUNvbG9yXCI6IFwiI0VDRUNGRlwiLFxuICAgIFwic2Vjb25kYXJ5Q29sb3JcIjogXCIjZmZmZmRlXCIsXG4gICAgXCJ0ZXJ0aWFyeUNvbG9yXCI6IFwiaHNsKDgwLCAxMDAlLCA5Ni4yNzQ1MDk4MDM5JSlcIixcbiAgICBcInByaW1hcnlCb3JkZXJDb2xvclwiOiBcImhzbCgyNDAsIDYwJSwgODYuMjc0NTA5ODAzOSUpXCIsXG4gICAgXCJzZWNvbmRhcnlCb3JkZXJDb2xvclwiOiBcImhzbCg2MCwgNjAlLCA4My41Mjk0MTE3NjQ3JSlcIixcbiAgICBcInRlcnRpYXJ5Qm9yZGVyQ29sb3JcIjogXCJoc2woODAsIDYwJSwgODYuMjc0NTA5ODAzOSUpXCIsXG4gICAgXCJwcmltYXJ5VGV4dENvbG9yXCI6IFwiIzEzMTMwMFwiLFxuICAgIFwic2Vjb25kYXJ5VGV4dENvbG9yXCI6IFwiIzAwMDAyMVwiLFxuICAgIFwidGVydGlhcnlUZXh0Q29sb3JcIjogXCJyZ2IoOS41MDAwMDAwMDAxLCA5LjUwMDAwMDAwMDEsIDkuNTAwMDAwMDAwMSlcIixcbiAgICBcImxpbmVDb2xvclwiOiBcIiMzMzMzMzNcIixcbiAgICBcInRleHRDb2xvclwiOiBcIiMzMzNcIixcbiAgICBcIm1haW5Ca2dcIjogXCIjRUNFQ0ZGXCIsXG4gICAgXCJzZWNvbmRCa2dcIjogXCIjZmZmZmRlXCIsXG4gICAgXCJib3JkZXIxXCI6IFwiIzkzNzBEQlwiLFxuICAgIFwiYm9yZGVyMlwiOiBcIiNhYWFhMzNcIixcbiAgICBcImFycm93aGVhZENvbG9yXCI6IFwiIzMzMzMzM1wiLFxuICAgIFwiZm9udEZhbWlseVwiOiBcIlxcXCJ0cmVidWNoZXQgbXNcXFwiLCB2ZXJkYW5hLCBhcmlhbFwiLFxuICAgIFwiZm9udFNpemVcIjogXCIxNnB4XCIsXG4gICAgXCJsYWJlbEJhY2tncm91bmRcIjogXCIjZThlOGU4XCIsXG4gICAgXCJub2RlQmtnXCI6IFwiI0VDRUNGRlwiLFxuICAgIFwibm9kZUJvcmRlclwiOiBcIiM5MzcwREJcIixcbiAgICBcImNsdXN0ZXJCa2dcIjogXCIjZmZmZmRlXCIsXG4gICAgXCJjbHVzdGVyQm9yZGVyXCI6IFwiI2FhYWEzM1wiLFxuICAgIFwiZGVmYXVsdExpbmtDb2xvclwiOiBcIiMzMzMzMzNcIixcbiAgICBcInRpdGxlQ29sb3JcIjogXCIjMzMzXCIsXG4gICAgXCJlZGdlTGFiZWxCYWNrZ3JvdW5kXCI6IFwiI2U4ZThlOFwiLFxuICAgIFwiYWN0b3JCb3JkZXJcIjogXCJoc2woMjU5LjYyNjE2ODIyNDMsIDU5Ljc3NjUzNjMxMjglLCA4Ny45MDE5NjA3ODQzJSlcIixcbiAgICBcImFjdG9yQmtnXCI6IFwiI0VDRUNGRlwiLFxuICAgIFwiYWN0b3JUZXh0Q29sb3JcIjogXCJibGFja1wiLFxuICAgIFwiYWN0b3JMaW5lQ29sb3JcIjogXCJncmV5XCIsXG4gICAgXCJzaWduYWxDb2xvclwiOiBcIiMzMzNcIixcbiAgICBcInNpZ25hbFRleHRDb2xvclwiOiBcIiMzMzNcIixcbiAgICBcImxhYmVsQm94QmtnQ29sb3JcIjogXCIjRUNFQ0ZGXCIsXG4gICAgXCJsYWJlbEJveEJvcmRlckNvbG9yXCI6IFwiaHNsKDI1OS42MjYxNjgyMjQzLCA1OS43NzY1MzYzMTI4JSwgODcuOTAxOTYwNzg0MyUpXCIsXG4gICAgXCJsYWJlbFRleHRDb2xvclwiOiBcImJsYWNrXCIsXG4gICAgXCJsb29wVGV4dENvbG9yXCI6IFwiYmxhY2tcIixcbiAgICBcIm5vdGVCb3JkZXJDb2xvclwiOiBcIiNhYWFhMzNcIixcbiAgICBcIm5vdGVCa2dDb2xvclwiOiBcIiNmZmY1YWRcIixcbiAgICBcIm5vdGVUZXh0Q29sb3JcIjogXCJibGFja1wiLFxuICAgIFwiYWN0aXZhdGlvbkJvcmRlckNvbG9yXCI6IFwiIzY2NlwiLFxuICAgIFwiYWN0aXZhdGlvbkJrZ0NvbG9yXCI6IFwiI2Y0ZjRmNFwiLFxuICAgIFwic2VxdWVuY2VOdW1iZXJDb2xvclwiOiBcIndoaXRlXCIsXG4gICAgXCJzZWN0aW9uQmtnQ29sb3JcIjogXCJyZ2JhKDEwMiwgMTAyLCAyNTUsIDAuNDkpXCIsXG4gICAgXCJhbHRTZWN0aW9uQmtnQ29sb3JcIjogXCJ3aGl0ZVwiLFxuICAgIFwic2VjdGlvbkJrZ0NvbG9yMlwiOiBcIiNmZmY0MDBcIixcbiAgICBcInRhc2tCb3JkZXJDb2xvclwiOiBcIiM1MzRmYmNcIixcbiAgICBcInRhc2tCa2dDb2xvclwiOiBcIiM4YTkwZGRcIixcbiAgICBcInRhc2tUZXh0TGlnaHRDb2xvclwiOiBcIndoaXRlXCIsXG4gICAgXCJ0YXNrVGV4dENvbG9yXCI6IFwid2hpdGVcIixcbiAgICBcInRhc2tUZXh0RGFya0NvbG9yXCI6IFwiYmxhY2tcIixcbiAgICBcInRhc2tUZXh0T3V0c2lkZUNvbG9yXCI6IFwiYmxhY2tcIixcbiAgICBcInRhc2tUZXh0Q2xpY2thYmxlQ29sb3JcIjogXCIjMDAzMTYzXCIsXG4gICAgXCJhY3RpdmVUYXNrQm9yZGVyQ29sb3JcIjogXCIjNTM0ZmJjXCIsXG4gICAgXCJhY3RpdmVUYXNrQmtnQ29sb3JcIjogXCIjYmZjN2ZmXCIsXG4gICAgXCJncmlkQ29sb3JcIjogXCJsaWdodGdyZXlcIixcbiAgICBcImRvbmVUYXNrQmtnQ29sb3JcIjogXCJsaWdodGdyZXlcIixcbiAgICBcImRvbmVUYXNrQm9yZGVyQ29sb3JcIjogXCJncmV5XCIsXG4gICAgXCJjcml0Qm9yZGVyQ29sb3JcIjogXCIjZmY4ODg4XCIsXG4gICAgXCJjcml0QmtnQ29sb3JcIjogXCJyZWRcIixcbiAgICBcInRvZGF5TGluZUNvbG9yXCI6IFwicmVkXCIsXG4gICAgXCJsYWJlbENvbG9yXCI6IFwiYmxhY2tcIixcbiAgICBcImVycm9yQmtnQ29sb3JcIjogXCIjNTUyMjIyXCIsXG4gICAgXCJlcnJvclRleHRDb2xvclwiOiBcIiM1NTIyMjJcIixcbiAgICBcImNsYXNzVGV4dFwiOiBcIiMxMzEzMDBcIixcbiAgICBcImZpbGxUeXBlMFwiOiBcIiNFQ0VDRkZcIixcbiAgICBcImZpbGxUeXBlMVwiOiBcIiNmZmZmZGVcIixcbiAgICBcImZpbGxUeXBlMlwiOiBcImhzbCgzMDQsIDEwMCUsIDk2LjI3NDUwOTgwMzklKVwiLFxuICAgIFwiZmlsbFR5cGUzXCI6IFwiaHNsKDEyNCwgMTAwJSwgOTMuNTI5NDExNzY0NyUpXCIsXG4gICAgXCJmaWxsVHlwZTRcIjogXCJoc2woMTc2LCAxMDAlLCA5Ni4yNzQ1MDk4MDM5JSlcIixcbiAgICBcImZpbGxUeXBlNVwiOiBcImhzbCgtNCwgMTAwJSwgOTMuNTI5NDExNzY0NyUpXCIsXG4gICAgXCJmaWxsVHlwZTZcIjogXCJoc2woOCwgMTAwJSwgOTYuMjc0NTA5ODAzOSUpXCIsXG4gICAgXCJmaWxsVHlwZTdcIjogXCJoc2woMTg4LCAxMDAlLCA5My41Mjk0MTE3NjQ3JSlcIlxuICB9XG59IiwidXBkYXRlRWRpdG9yIjpmYWxzZSwiYXV0b1N5bmMiOnRydWUsInVwZGF0ZURpYWdyYW0iOmZhbHNlfQ)
