#!/bin/bash

server=$1

drupal_root=/var/www/html/drupal
roles_files_dir=roles/islandora_copy_hacks/files
scp_user=root

copy_hack () {
	mkdir -p ${roles_files_dir}/$2
	scp ${scp_user}@$1:${drupal_root}/$2/$3 ${roles_files_dir}/$2
}


copy_hack $server web/modules/contrib/metatag/src/Plugin/metatag/Tag MetaNameBase.php
copy_hack $server web/modules/contrib/metatag/src MetatagToken.php 

