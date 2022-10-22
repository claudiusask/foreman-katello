### Commands to enter while setup of Foreman-katello. 
1. First we create content-credentials; with content-credentials we import the GPG key to verify the downloadable repos. Find the URL for the respected software developer and OS. e.g: CentOS, Ubuntu etc..
	
	a. We create a new directory in /etc/pki/rpm-gpg/import 

		wget https://**--find-the-GPG-key-online.com--**
		
		hammer content-credentials create --path 'downloaded-key in /import' \
		--name 'name-to-give-to-key' --content-type 'gpg_key'		

2. Now create product; give it a name and details.

4. 		hammer product create --name 'example-name:CentOS8' --description 'description to give'

6. With product in place create repository from this product. Find the repo url on the respected OS.

		hammer repository create --product 'example-name:CentOS8' \
		--name 'examplename' --label 'examplename' --content-type yum \
		--download policy 'on_demand' --gpg-key-id '#get the number from content-credentials list' \
		--url 'the-repo-url-of-the-package' --mirror-on-sync 'no' 
		
8. With all these things in-place we can sync the repository with hammer in CLI or with web-interface, use tmux or screen with CLI. If any repo fails to sync please find the solutions below. For the below automated script we can use the for loop in bash cli. To find the number of items to loop in the seq we can do:- 
		<b>hammer repository list</b>

		for i in $(seq 1 15); do hammer repository synchronize --product "example-name:CentOS8" --id "$i"; done

10. For Remi php 8.0 use this repo url https://rpms.remirepo.net/enterprise/remi-release-8.rpm
11. Remember that graylog only works with Elasticsearch 7.11 otherwise use opensearch. Use the following repo url for elasticsearch 7.11 https://artifacts.elastic.co/packages/7.x/yum & for graylog use https://packages.graylog2.org/repo/el/stable/4.0/x86_64
12. Now we move to content-View, which is snapshot of one or more repositories and/or puppet modules.
13. We create the content-view add the repositories with ID and publish it. If we already have the content-view and we just want to add some more repositories we don't have to re-create it but we just add the repos and publish a new version.

		hammer content-view create --name "new_name_Content_View" --description "give it a description"
		
		for i in $(seq 1 27); do hammer content-view add-repository --name "new_name_Content_View" --product "name_of_repos" --repository-id "$i"; done
		
14. Now we create and activation-key which is used to register the host or server. Create the activation-key and then add-subscription to this activation-key. You can find the subscription number with command #hammer subscription list.  
