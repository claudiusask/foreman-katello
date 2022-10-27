1. Create Domain if it's already not created; check with <b>hammer domain list</b>.
2. In order to create a subnet we need to know our TFTP ID. TFTP ID is actually our proxy ID. Check with <b>hammer proxy list</b>.
3. Create the subnet:

            hammer subnet create \
            --organizations "my_Organization" \
            --locations "my_Location" \
            --name "homelab_LAN" \
            --network "10.0.0.0" \
            --mask "255.255.255.0" \
            --network-type "IPv4" \
            --gateway "10.0.0.1" \
            --dns-primary "10.0.0.xx" \
            --dns-secondary "10.0.0.xx" \
            --boot-mode "DHCP" \
            --ipam "None" \
            --domain-ids "1" \
            --tftp-id "1"
