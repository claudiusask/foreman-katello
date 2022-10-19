### Commands to enter while setup of Foreman-katello. 
1. First we create content-credentials; with content-credentials we import the GPG key to verify the downloadable repos. Find the URL for the respected software developer and OS. e.g: CentOS, Ubuntu etc..
	
	a. We create a new directory in /etc/pki/rpm-gpg/import 

		wget https://**--find-the-GPG-key-online.com--**
		
		hammer content-credentials create --key 'downloaded-key in /import' -name 'name-to-give-to-key' -content-type 'gpg_key'		

2. Now create product; give it a name and details.

4. 		hammer product create --name 'example-name:CentOS8' --description 'description to give'

6. With product in place create repository from this product. Find the repo url on the respected OS.

		hammer repository create --product 'example-name:CentOS8' --content-type yum 
		
8. With all these things in-place we can sync the repository with hammer in CLI or with web-interface, use tmux or screen with CLI.
9. Now we move to content-View, which is snapshot of one or more repositories and/or puppet modules. 
10. We create the content-view and publish it. Add the repositories with ID and publish it.
11. Now we create and activation-key which is used to register the host or server. Create the activation-key and then add-subscription to this activation-key. You can find the subscription number with command #hammer subscription list.  
