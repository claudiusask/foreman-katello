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

10. Sometimes it's difficult to find the repos URL. What we can do is find Manual installation in the documentation of the repository or Software. Look for something like <b>"create a file named <i>/etc/yum.repos.d/graylog.repo</i>"</b> and extract the baseurl.
11. For Remi php 8.0 use this repo url https://rpms.remirepo.net/enterprise/remi-release-8.rpm
12. Remember that graylog only works with Elasticsearch 7.11 otherwise use opensearch. Use the following repo url for elasticsearch 7.11 https://artifacts.elastic.co/packages/7.x/yum & for graylog use https://packages.graylog2.org/repo/el/stable/4.0/x86_64
13. Now we move to content-View, which is snapshot of one or more repositories and/or puppet modules.
14. We create the content-view, add the repositories with ID and publish it. If we already have the content-view and we just want to add some more repositories we don't have to re-create it but we just add the repos and publish a new version.

		hammer content-view create --name "new_name_Content_View" --description "give it a description"
		
		for i in $(seq 1 27); do hammer content-view add-repository --name "new_name_Content_View" --product "name_of_repos" --repository-id "$i"; done
		
		hammer content-view publish --name "new_name_Content-View" --description "Publishing vx.x"
		
14. Create a new Lifecycle. A lifecycle environment is like a container for content view versions which are used by content hosts. We can have different “containers” for different lifecycle environments (eg. Ddevelopment, Testing, Production).
	
		hammer lifecycle-environment create --name "new_name_LFC" --label "same_like_name_or_bit_different" --prior "Library" or "Dev" or "Test" or "Prod"
		
		hammer content-view version promote --content-view "new_name_Content-View" --version "2.0" --to-lifecycle-environment "new_name_LFC"
				
15. Now we create and activation-key which is used to register the host or server. Create the activation-key and then add-subscription to this activation-key. You can find the subscription number with command #hammer subscription list. To find the content-view-id run; <b>hammer content-view version list</b>

		hammer activation-key create --name "new_key_name" --description "description for user information" --lifecycle-environment "new_name_LFC" --content-view-id #

16. The subscription is an entitlement for receiving content and service from the respected software Devs. In this step we add the subscription id's to the Activation keys. To find the subscription-id we do: <b>hammer subscription list</b>

		for i in $(seq 1 3); do hammer activation-key add-subscription --name "new_key_name" --quantity 1 --subscription-id "$i"; done
	
