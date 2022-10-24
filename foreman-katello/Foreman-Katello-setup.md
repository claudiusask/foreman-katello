These are the instructions to build the basic Foreman Katello server from scratch. The plan is to use newly provisioned sever with nothing configured. We change the hostname and ip address.

1. The first thing we do is change the hostname to katello.domain.com <i>(we can name whatever we like to name this server)</i>. Also change the ip address, we have already setup DNS and DHCP on another server with 2nd slave server incase of Mater failure.
2. Now we need to open the ports for Foreman-Katello. We open the ports with the following commands:
      
            firewall-cmd \
            --add-port="69/udp" \
            --add-port="80/tcp" --add-port="443/tcp" \
            --add-port="5647/tcp" \
            --add-port="8140/tcp" \
            --add-port="8443/tcp" \
            --add-port="8000/tcp" --add-port="9090/tcp"
     
3. Now check
