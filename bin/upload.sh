#!/bin/bash
read -p "What is the upload server? FDQN: " server_name

wao_folder="/home/raymond/Documents/work/anatomy/Wao"
wao_extras_folder="/home/raymond/Documents/work/anatomy/WaoExtras"
wao_upload_folder="citpub@$server_name:/home/citpub/Data_for_Ontology"
anat_ace_upload_folder="citpub@$server_name:/home/citpub/Data_for_citace/Data_from_Raymond"

read -p "What WS version to upload? WS " ws_ver

cd $wao_folder
git status  # need varification step here, if OK

read -p "Git status looks OK to continue? y or n: " git_ok
if ! [ $git_ok == "y" ]; then
	echo "OK. You need to git a bit more. Bye."
	exit 1
fi

scp $wao_folder/WBbt.obo $wao_upload_folder/anatomy_ontology.WS$ws_ver.obo

cd $wao_extras_folder
echo $PWD
./obo2ace.pl WBbt.obo > temp.ace
testfilesize=$(stat -c%s temp.ace)
echo "Replacement ace file size = "  $testfilesize
wbbtacefilesize=$(stat -c%s WBbt.ace)
echo "Current WBbt.ace file size = "  $wbbtacefilesize
if [ $wbbtacefilesize -gt $testfilesize ]; then
	read -p "Are you OK with new ace file getting smaller? y/n: " ace_ok
	if ! [ $ace_ok == "y" ]; then
		echo "New ace file too small, go fix the problem first. Bye"
		exit 1
	fi
else
	mv temp.ace WBbt.ace
	git commit -a      # "Updated for WS$ws_ver."
fi

read -p "New anatomy function or other ace files to fix before upload? y/n: " other_ace_ok
if ! [ $other_ace_ok == "n" ]; then
	echo "OK. You need to fix more ace files. Bye."
	exit 1
fi

scp -r $wao_extras_folder/*.ace $anat_ace_upload_folder/.

echo "\n\nAll done. Bye"

