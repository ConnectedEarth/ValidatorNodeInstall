#!/bin/bash


#If you would like to see debug messagesm uncomment the following line
set -x

echo "Install dependencies....."


sudo apt -q update;
sudo apt -q install zenity -y;
sudo apt -q install jq -y;
sudo apt -q install unzip -y;
sudo apt -q install sshpass -y;

# Arrays to store user id, passwords, and remote host ips
user_ids=()
passwords=()
remote_ips=()

# Function to perform rollback
rollback() {
    local num_commands=${#user_ids[@]}
    local config_file="$1"

    # Rollback each executed command
    for ((i = 0; i < num_commands; i++)); do
	sshpass -p"${passwords[$i]}" ssh -t -o 'StrictHostKeyChecking=no' "${user_ids[$i]}@${remote_ips[$i]}" "cp \"$config_file.bkp\" \"$config_file\""
	sshpass -p"${passwords[$i]}" ssh -t -o 'StrictHostKeyChecking=no' "${user_ids[$i]}@${remote_ips[$i]}" "echo ${PASSWORD} |sudo -S systemctl stop cosmovisor.service"
	sleep 5
	sshpass -p"${passwords[$i]}" ssh -t -o 'StrictHostKeyChecking=no' "${user_ids[$i]}@${remote_ips[$i]}" "echo ${PASSWORD} |sudo -S systemctl start cosmovisor.service"
	
        #execute_remote_command "${user_ids[$i]}" "${passwords[$i]}" "${remote_ips[$i]}" "your_rollback_command_here"
    done
}

#PASSWORD=$(zenity --password --width=500 --title="Please enter your SUDO password")
#if [ ! -z "$PASSWORD" ]; then
#    #echo "Your password: $PASSWORD"
        #Elevate the user to admin
#        pw=$(echo $PASSWORD | cut -d'|' -f1);
        #TMP=$(echo "${pw}" | sudo -Sv);
	#echo $TMP
#fi	

#		INTERVAL=100
		#LATEST_HEIGHT=$(curl -s "$remote_host":"$rpc_server_port/block" | jq -r .result.block.header.height)
#		curl "$remote_host":"$rpc_server_port/block" > output.txt 2> error.log 
#		LATEST_HEIGHT=$(cat output.txt | jq -r .result.block.header.height)
#		BLOCK_HEIGHT=$((($((LATEST_HEIGHT / INTERVAL)) - 1) * INTERVAL + $((INTERVAL / 2))))
#		TRUST_HASH=$(curl "$remote_host":"$rpc_server_port/block?height=${BLOCK_HEIGHT}" | jq -r .result.block_id.hash)		

(
	echo 1
	echo "# Setting up environment vatiables for AYA installation.."
	sleep 2
	aya_home=$(zenity --entry --width 500 --title "AYA Home" --text "AYA HOME DIRECTORY" --entry-text="/opt/aya");
	if [ $? -ne 0 ]; then
		exit 1;
	fi

	cosmovisor_logfile="${aya_home}/logs/cosmovisor.log"
	registration_setup_json="${aya_home}/registration.json"
	#1bootstrap_node=true

	echo 2
	echo "# Checking for AYA installation"
	if [ -d "${aya_home}" ]; then 

		$(zenity --question --title "Question" --width 500 --text "An existing Aya installation may already exists in the directory you selected \n Continue?");
	fi


	if [ $? -eq 0 ]; then



		sudo rm -rf "${aya_home}";
		sudo systemctl stop cosmovisor
		sudo systemctl disable cosmovisor
		kill -9 $(ps -ef | grep -w "${aya_home}/cosmovisor/cosmovisor run start"|awk 'NR==1{print $2}')
		kill -9 $(ps -ef | grep -w "${aya_home}/cosmovisor/genesis/bin/ayad start"|awk 'NR==1{print $2}')
	
		echo 3
		echo "# Please confirm  Chain ID"
		
		CHAIN_ID=$(zenity --entry --width 500 --title "AYA CHAIN ID" --text "AYA Chain ID" --entry-text="aya_preview_501");
		if [ $? -ne 0 ]; then
			exit 1;
		fi

		echo 4
		echo "# Please provide  Moniker name"
		moniker=$(zenity --entry --width 500 --title "MONIKER" --text "moniker name");
		if [ $? -ne 0 ]; then
			exit 1;
		fi

		if [ -z "$moniker" ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Moniker cannot be empty...EXITING!"
			exit 1;

		fi	

		echo 5
		echo "# Please provide  Account  name"
		account=$(zenity --entry --width 500 --title "MONIKER" --text "Operator Account name (can be same as Moniker)");
		if [ $? -ne 0 ]; then
			exit 1;
		fi

		if [ -z "$account" ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Account name cannot be empty...EXITING!"
			exit 1;

		fi	

		echo 6
		echo "# Starting Installation..."


		echo 7
		echo "# creating installation directory for Aya ..." 
		#TMP=$(echo "${pw}" | sudo -S mkdir -p ${aya_home});
		sudo mkdir -p "${aya_home}";
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home} directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" | sudo -S chown "${USER}:${USER}" ${aya_home});
		sudo chown "${USER}:${USER}" "${aya_home}";
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: could not change ownersip on ${aya_home} directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/cosmovisor/genesis/bin)
		mkdir -p "${aya_home}/cosmovisor/genesis/bin"
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/cosmovisor/genesis/bin directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/backup)
		mkdir -p "${aya_home}/backup"
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/backup directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/logs)
		mkdir -p "${aya_home}/logs"
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/logs directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/config)
		mkdir -p "${aya_home}/config"
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/config directory"
			exit 1;
		fi


		echo 10
		echo "# Fetching  necessary files......" 


		if [ -d ~/earthnode_installer ]; then 
			rm -rf ~/earthnode_installer
		fi

		mkdir ~/earthnode_installer
		cd ~/earthnode_installer

		install_file=$(zenity --entry --width 500 --title "Repository file location" --text "Confirm the files that are being fetched..." --entry-text="https://github.com/max-hontar/aya-preview-binaries/releases/download/v0.4.1/aya_preview_501_installer_2023_09_04.zip");
		if [ $? -ne 0 ]; then
			exit 1;
		fi

		wget "${install_file}"
		if [ $? -ne 0 ]; then

			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not download installation files...exiting"
			exit 1;
		fi
		unzip aya_preview_501_installer_2023_09_04.zip
		rm aya_preview_501_installer_2023_09_04.zip

		echo 11
		echo "# Checking for checksum"
		#sha256sum ayad cosmovisor

		#zenity --info --title "Info Message" --width 500 --height 200 --text="Please verify checksum...\n\n $(cat release_checksums)"
		zenity --info --title "Info Message" --width 500 --height 200 --text="Please verify checksum...\n\n $(sha256sum ayad cosmovisor)"

		if [ $? -ne 0 ]; then
			exit 1;
		fi

		echo 12
		echo "# Copying installation files"
		cp ~/earthnode_installer/ayad "${aya_home}/cosmovisor/genesis/bin/ayad"
		cp ~/earthnode_installer/cosmovisor "${aya_home}/cosmovisor/cosmovisor"		


		echo 13
		echo "# Initialying ayad to populate /opt/aya"
		./ayad init "${moniker}" --chain-id $CHAIN_ID --home "${aya_home}"

		echo 14
		echo "# Copying genesis.json file"
		cp ~/earthnode_installer/genesis.json "${aya_home}/config/genesis.json"

		echo 18
		echo "# Creating a new Operator Account"
		# Create a new operator account and store the JSON output in the 'operator_json' variable
		read -r -d '' keyring_password_msg <<- EOM
			ATTENTION: Please read carefully…

			Program will execute the following command, this will add keys and create keyring password:
			
			./ayad keys add "${account}" --output json --home "${aya_home}"

			Please enter KEYRING Password in the Console To proceed with the installation
		EOM

		zenity --info --title "Info Message" --width 500 --height 200 --text "$keyring_password_msg";

		operator_json=$(./ayad keys add "${account}" --output json --home "${aya_home}")
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not setup Keyring password!...Exiting!"
			exit 1;
		fi

		operator_json_formatted=$(echo "$operator_json" | jq -M) 

		# Extract the address from the 'operator_json' variable and store it in the 'operator_address' variable
		operator_address=$(echo "$operator_json" | jq '.address' | sed 's/\"//g')


		echo 20
		echo "# Display the mnemonic and address of the operator account"
		zenity --info --title "Info Message" --width 500 --height 200 --text "[ONLY FOR YOUR EYES] Store this information safely, the mnemonic is the only way to recover your account.\n\n\n ${operator_json_formatted}"

		validator_node_id=$(./ayad tendermint show-node-id --home "${aya_home}")


		echo 22
		echo "# Preparing to hook up sentry nodes"
		number_of_Snodes=$(zenity --entry --width 500 --title "Sentry node #" --text "How many Sentry nodes(default=2) that will be used?" --entry-text "2");

		if [ $number_of_Snodes -lt 2 ]; then

			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: You need atleast 2 Sentry Nodes to bootsrap validator...Exiting!"
			exit 1
		fi	

		sentry_node_counter=1
		old_remote_host="dummy"
		sentry_node_ids="dummy"
		sentry_node_ids_ips="dummy"
		sentry_port=26656

		rpc_servers_ips="dummy"
		rpc_server_port=26657

#		INTERVAL=100
#		LATEST_HEIGHT=$(curl -s "$remote_host":"$rpc_server_port/block" | jq -r .result.block.header.height)
		#curl "$remote_host":"$rpc_server_port/block" > output.txt 2> error.log 
		#LATEST_HEIGHT=$(cat output.txt | jq -r .result.block.header.height)
#		BLOCK_HEIGHT=$((($((LATEST_HEIGHT / INTERVAL)) - 1) * INTERVAL + $((INTERVAL / 2))))
#		TRUST_HASH=$(curl "$remote_host":"$rpc_server_port/block?height=${BLOCK_HEIGHT}" | jq -r .result.block_id.hash)		

		while [ $number_of_Snodes -gt 0 ];
		do
    			#echo $number_of_Snodes

			echo 24
			echo "# Configuring Sentry Node $sentry_node_counter"

			remote_host=$(zenity --entry --width 500 --title "Sentry Node $sentry_node_counter  IP" --text "Enter Sentry Node $sentry_node_counter  IP address" --entry-text="xx.xx.xx.xx");

        		if [ $? -ne 0 ]; then
				echo "# rolling back...."
				rollback "$config_file"
                		exit 1;
        		fi


			if [ "$old_remote_host" =  "$remote_host" ]; then
					
				echo "# rolling back...."
				rollback "$config_file"
				zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: IP Address for Sentry node is already provided and configured\n \
					 you need to provide a new IP address to continue...
					 Please try running the installation script again... Exiting!"	
				exit 1	 
			fi

			old_remote_host=$remote_host
			if [ "$sentry_node_counter" -eq 1 ]; then
				PEER1="$remote_host"
			fi	

			RMT_USR=$(zenity --entry --width 500 --title "Please enter your remote User" --text "Enter Sentry Node $sentry_node_counter host User:");
        		if [ $? -ne 0 ]; then
				echo "# rolling back...."
				rollback "$config_file"
               			exit 1;
        		fi

			PASSWORD=$(zenity --entry --width 500 --title "Please enter your SSH password" --text "Enter Sentry Node $sentry_node_counter host password for User '${RMT_USR}'" --hide-text);
        		if [ $? -ne 0 ]; then
				echo "# rolling back...."
				rollback "$config_file"
                		exit 1;
        		fi

			echo "# Configuring Sentry Node $sentry_node_counter ... Validating remote Username and Password"
			sshpass -p "$PASSWORD" ssh -t -o 'StrictHostKeyChecking=no' "$RMT_USR"@"$remote_host" "echo success" 2>/dev/null

			#This is with -t (terminate option)
			#sshpass -p "$PASSWORD" ssh  -t -o 'StrictHostKeyChecking=no' ConnectTimeout=5 "$RMT_USR"@"$remote_host" "echo success" 2>/dev/null

        		if [ $? -ne 0 ]; then
				zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: cannot validate the credential entered against the host $remote_host\n\n \ 
					Please execute the following command from the terminal \n\n \
					ssh "$RMT_USR"@"$remote_host"\n\n  \
					And make sure that you have a connectivity to the sentry node host machine\n\n \
					Once connectivity is confirmed, re-run this script again\n\n \
					..Exiting!"
				echo "# rolling back...."
				rollback "$config_file"
                		exit 1;
        		fi


			SentryAyaHome=$(zenity --entry --width 500 --title "Sentry AYA home directory" --text "Confirm Sentry Node $sentry_node_counter AYA Home directory" --entry-text="/opt/aya");
        		if [ $? -ne 0 ]; then
                		exit 1;
        		fi

			
			if [ "$rpc_servers_ips" =  "dummy" ]; then
				rpc_servers_ips="$remote_host":"$rpc_server_port"
			else	
				rpc_servers_ips="$rpc_servers_ips","$remote_host":"$rpc_server_port"
			fi

			
			SentryNodeId=$(sshpass -p"${PASSWORD}" ssh -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "echo ${PASSWORD} | sudo -S ayad tendermint show-node-id --home ${aya_home}")

			sleep 1
			if [ "$sentry_node_ids" =  "dummy" ]; then
				sentry_node_ids="$SentryNodeId"
			else	
				sentry_node_ids="$sentry_node_ids","$SentryNodeId"
			fi


			if [ "$sentry_node_ids_ips" =  "dummy" ]; then
				sentry_node_ids_ips="$SentryNodeId"@"$remote_host":"$sentry_port"
			else	
				sentry_node_ids_ips="$sentry_node_ids_ips","$SentryNodeId"@"$remote_host":"$sentry_port"
			fi

			sleep 1

			echo "# Configuring Sentry Node $sentry_node_counter, Creating backup for config.toml"
			config_file="${SentryAyaHome}/config/config.toml"

			sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "cp \"$config_file\" \"$config_file\".bkp"

			#This code block is to update "unconditional_peer_ids" in Sentry"	
			if sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "grep -q 'unconditional_peer_ids = \"\"' $config_file"; then
				echo "replacing...."
				sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/unconditional_peer_ids =/s/unconditional_peer_ids = .*/unconditional_peer_ids = \"$validator_node_id\"/' \"$config_file\""

				sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/private_peer_ids =/s/private_peer_ids = .*/private_peer_ids = \"$validator_node_id\"/' \"$config_file\""
			else
				
				install_msg=$(cat <<- EOM
				ATTENTION: Please read carefully…

				An existing configuration is detected while updating the Sentry Nodes configuration:

				At host "${remote_host}" in "${config_file}"

				This can happen if you are re-installing the validator node

				OR

				Adding a new validator node to an existing setup.

				Choose the correct option based on your situation in the next screen
				EOM
				)				
				
 				zenity --info --title "Info Message" --width 500 --height 200 --text "$install_msg"

				Option=$(zenity --list --radiolist --width 500 --title "Install Options" --column "Select" --column "Options" FALSE "Re-install validator" FALSE "Add new validator to existing setup")
	                        if [ $? -ne 0 ]; then
					echo "# rolling back...."
					rollback "$config_file"
					exit 1;
                        	fi


			       	if [ "$Option" = "Add new validator to existing setup" ]; then	
					echo "Appending...."
					sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/unconditional_peer_ids =/s/.$/,$validator_node_id\"/' \"$config_file\""
					sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/private_peer_ids =/s/.$/,$validator_node_id\"/' \"$config_file\""
				else
					sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/unconditional_peer_ids =/s/unconditional_peer_ids = .*/unconditional_peer_ids = \"$validator_node_id\"/' \"$config_file\""
					sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/private_peer_ids =/s/private_peer_ids = .*/private_peer_ids = \"$validator_node_id\"/' \"$config_file\""
				fi
			fi

			#Set the laddr = “tcp://127.0.0.1:26657” field to be laddr = “tcp://0.0.0.0:26657” in the RPC Server Configuration Options section of the file.

			new_val_rpc_laddr="tcp://0.0.0.0:26657"
			sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/\[rpc\]/,/laddr =/ s|laddr = .*|laddr = \"${new_val_rpc_laddr}\"|' \"$config_file\""

			#Set snapshot interval to 100 instead of 0 to activate the snapshot manager 
			config_file_app="${SentryAyaHome}/config/app.toml"
			new_val_snapshot_interval=100
			sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "sed -i '/snapshot-interval =/s/snapshot-interval = .*/snapshot-interval = \"${new_val_snapshot_interval}\"/'  \"$config_file_app\""

			echo "# Configuring Sentry Node $sentry_node_counter, Updating Firewall"

			firewall_port_to_open=26656

read -r -d '' firewall_warning_text <<- EOM
ATTENTION: This is Firewall setup for Sentry Node "$sentry_node_counter"
Please read carefully…
This is the most CRITICAL step in the installation process

In the next step you will see 3 options for firewall selection

*** UFW
*** IP Tables
*** Manual

If you are not sure on Firewall, your safest bet probably will be “IP Tables” selection.
If you are selecting manual, please make sure port number "${firewall_port_to_open}" is opened using TCP protocol.
EOM
			
			#updating FW information
			zenity --info --title "Info Message" --width 500 --height 200 --text "$firewall_warning_text";

			Firewall=$(zenity --list --radiolist --title "Firewall Menu" --column "Select" --column "Firewall" FALSE "UFW" FALSE "IP Tables", FALSE "Others(Manual)")	
	                if [ $? -ne 0 ]; then
				echo "# rolling back...."
				rollback "$config_file"
				exit 1;
                        fi

			if [ ${Firewall} = "UFW" ]; then
				sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "echo ${PASSWORD} |sudo -S ufw allow from any to any port ${firewall_port_to_open} proto tcp";
			elif [ ${Firewall} = "IP Tables" ]; then	
				sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "echo ${PASSWORD} |sudo -S iptables -I INPUT -p tcp -m tcp --dport ${peer1_port} -j ACCEPT";
				sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "echo ${PASSWORD} |sudo -S service iptables save";
			else
				zenity --info --title "Info Message" --width 500 --height 100 --text "Please make sure port number "${firewall_port_to_open}" is opened using TCP protocol.";
			fi

			echo "# Configuring Sentry Node $sentry_node_counter, restarting Cosmovisor service"
			sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "echo ${PASSWORD} |sudo -S systemctl stop cosmovisor.service"
			sleep 5
			sshpass -p"${PASSWORD}" ssh -t -o 'StrictHostKeyChecking=no' "${RMT_USR}@${remote_host}" "echo ${PASSWORD} |sudo -S systemctl start cosmovisor.service"
			sleep 5

			# Store user id, password, and remote host ip
			user_ids+=("$RMT_USR")
			passwords+=("$PASSWORD")
			remote_ips+=("$remote_host")


    			((number_of_Snodes--))
    			((sentry_node_counter++))
		done


		# Starting to configure the validator node, config.toml
		echo 25
		echo "# Updating validaror node config.toml"
		


		old_val_statesync="false"
		old_val_addr_book_strict="true"
		old_val_log_level="info"
		old_val_persistent_peer=""
		old_val_unconditional_peer_ids=""
		old_val_pex="true"
		old_val_max_dial_period="0s"

		new_val_statesync="true"
		new_val_addr_book_strict="false"
		new_val_log_level="error"
		new_val_persistent_peer="$sentry_node_ids_ips"
		new_val_unconditional_peer_ids="$sentry_node_ids"		
		new_val_pex="false"
		new_val_max_dial_period="10s"


		sed -i "/statesync/,/enable/ s/enable = .*/enable = ${new_val_statesync}/" "${aya_home}/config/config.toml"
		sed -i "/addr_book_strict/s/addr_book_strict = .*/addr_book_strict = ${new_val_addr_book_strict}/" "${aya_home}/config/config.toml"
		sed -i "/log_level/s/log_level = .*/log_level = \"${new_val_log_level}\"/" "${aya_home}/config/config.toml"
		sed -i "/persistent_peers/s/persistent_peers = .*/persistent_peers = \"${new_val_persistent_peer}\"/" "${aya_home}/config/config.toml"
		sed -i "/unconditional_peer_ids/s/unconditional_peer_ids = .*/unconditional_peer_ids = \"${new_val_unconditional_peer_ids}\"/" "${aya_home}/config/config.toml"
		sed -i "/pex/s/pex = .*/pex = ${new_val_pex}/" "${aya_home}/config/config.toml"		
		sed -i "/persistent_peers_max_dial_period/s/persistent_peers_max_dial_period = .*/persistent_peers_max_dial_period  = \"${new_val_max_dial_period}\"/" "${aya_home}/config/config.toml"

		sleep 5

		INTERVAL=100
		LATEST_HEIGHT=$(curl -s "$PEER1":"$rpc_server_port/block" | jq -r .result.block.header.height)
		#curl "$remote_host":"$rpc_server_port/block" > output.txt 2> error.log
		#LATEST_HEIGHT=$(cat output.txt | jq -r .result.block.header.height)
		BLOCK_HEIGHT=$((($((LATEST_HEIGHT / INTERVAL)) - 1) * INTERVAL + $((INTERVAL / 2))))
		TRUST_HASH=$(curl "$PEER1":"$rpc_server_port/block?height=${BLOCK_HEIGHT}" | jq -r .result.block_id.hash)
		

                if [ "$BLOCK_HEIGHT" -lt 0 ]; then
                        zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Error calculating Block Heigh..Cannot proceed..Exiting!!"
			echo "# rolling back...."
			rollback "$config_file"
                        exit 1;
                fi

		# Set available RPC servers (at least two) required for light client snapshot verification
		sed -i -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$rpc_servers_ips\"|" "${aya_home}/config/config.toml"
		# Set "safe" trusted block height
		sed -i -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT|" "${aya_home}/config/config.toml"
		# Set "qsafe" trusted block hash
		sed -i -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" "${aya_home}/config/config.toml"
		# Set trust period, should be ~2/3 unbonding time (3 weeks for preview network)
		sed -i -E "s|^(trust_period[[:space:]]+=[[:space:]]+).*$|\1\"302h0m0s\"|" "${aya_home}/config/config.toml"

		echo 30
		echo "# updating app.toml before running Validator node for the  first time..."

		new_val_grpc_addr="localhost:29090"
	       	new_val_minimum_gas_prices="0uswmt"
		new_val_api="true"

		sed -i "/\[grpc\]/,/address =/ s/address = .*/address = \"${new_val_grpc_addr}\"/" "${aya_home}/config/app.toml"
		sed -i "/minimum-gas-prices =/s/minimum-gas-prices = .*/minimum-gas-prices = \"${new_val_minimum_gas_prices}\"/" "${aya_home}/config/app.toml"
		sed -i "/\[api\]/,/enable =/ s/enable = .*/enable = ${new_val_api}/" "${aya_home}/config/app.toml"

		echo 35
		echo "# exporting environment variables..."

		export DAEMON_NAME=ayad
		export DAEMON_HOME="${aya_home}"
		export DAEMON_DATA_BACKUP_DIR="${aya_home}/backup"
		export DAEMON_RESTART_AFTER_UPGRADE=true
		export DAEMON_ALLOW_DOWNLOAD_BINARIES=true
		ulimit -Sn 4096		
		
		"${aya_home}/cosmovisor/cosmovisor" run start --home "${aya_home}" &>>"${cosmovisor_logfile}" &

		sleep 5

                if [ $? -ne 0 ]; then
                        zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Cosmovisor service did not run correctly...Existing!!"
			echo "# rolling back...."
			rollback "$config_file"
                        exit 1;
                fi

                echo 45
                echo "# Consmovisor started successfully!"

		sleep 3 

                echo 50 
                echo "# Starting Synching proess..."

		cd ~/earthnode_installer
		#catch_up=$(./ayad status | jq -r .SyncInfo.catching_up)
		latest_height_local=$(./ayad status | jq -r .SyncInfo.latest_block_height)
		latest_height_global=$(curl -s "http://peer1-501.worldmobilelabs.com:26657/block" | jq -r .result.block.header.height)
		prev_height_local=0

		if [ -z $latest_height_local ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Ayad not running, something went wrong! EXITING...."
			echo "# rolling back...."
			rollback "$config_file"
			exit 1;
		fi

		#while [ $catch_up = "true" ];
		while [ "$latest_height_local" -lt "$latest_height_global" ];
		do

			#calc() { awk "BEGIN{ printf \"%.2f\n\", $* }"; }

                        if [ ${prev_height_local} -eq 0 ] && [ ${latest_height_local} -gt 0 ]; then

				initial_delta=$(awk "BEGIN { printf(\"%.2f\", $latest_height_global - $latest_height_local) }")
			elif  [ $latest_height_local -gt 0 ]; then
				delta=$(awk "BEGIN { printf(\"%.2f\", $latest_height_global - $latest_height_local) }")
				result_division=$(awk "BEGIN { printf(\"%.2f\", $delta / $initial_delta) }")
				result_sub=$(awk "BEGIN { printf(\"%.2f\", 1 - $result_division) }")
				progress=$(awk "BEGIN { printf(\"%.2f\", $result_sub*100) }")

				echo "# Synching...$progress"

			fi


			prev_height_local="${latest_height_local}"

			latest_height_global=$(curl -s "http://peer1-501.worldmobilelabs.com:26657/block" | jq -r .result.block.header.height)
			latest_height_local=$(./ayad status | jq -r .SyncInfo.latest_block_height)
			echo "still catching up...Block height Local = ${latest_height_local} *** Block height Global =${latest_height_global}"

			sleep 10
			catch_up=$(./ayad status | jq -r .SyncInfo.catching_up)
		done

		
                echo 70 
                echo "# Cleaning up config.toml"

		sed -i "/statesync/,/enable/ s/enable = .*/enable = ${old_val_statesync}/" "${aya_home}/config/config.toml"

                echo 74
                echo "# Saving all imortant data of the running node..."


		cd ~/earthnode_installer
		# Get the address of the validator
		validator_address=$(./ayad tendermint show-address --home "${aya_home}")
		# Use 'jq' to create a JSON object with the 'moniker', 'operator_address' and 'validator_address' fields
		#jq --arg key0 'moniker' \
		#--arg value0 "$moniker" \
		#--arg key1 'validator_address' \
		#--arg value1 "$validator_address" \
		#'. | .[$key0]=$value0 | .[$key1]=$value1'  \
		#<<<'{}' | tee "$registration_setup_json"

		jq --arg key0 'moniker' \
		--arg value0 "$moniker" \
		--arg key1 'operator_address' \
		--arg value1 "$operator_address" \
		--arg key2 'validator_address' \
		--arg value2 "$validator_address" \
		'. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2' \
		<<<'{}' | tee "$registration_setup_json"

		sleep 1


                echo 78
                echo "# creating symbolic links....Please enter your SUDO password if system asks"
		sudo ln -s $aya_home/cosmovisor/current/bin/ayad /usr/local/bin/ayad >/dev/null 2>&1
		sudo ln -s $aya_home/cosmovisor/cosmovisor /usr/local/bin/cosmovisor >/dev/null 2>&1

		sleep 1

                echo 80
                echo "# creating systemd service file...."



sudo tee /etc/systemd/system/cosmovisor.service > /dev/null <<EOF
# Start the 'cosmovisor' daemon
# Create a Systemd service file for the 'cosmovisor' daemon
[Unit]
Description=Aya Node
After=network-online.target

[Service]
User=$USER
# Start the 'cosmovisor' daemon with the 'run start' command and write output to journalctl
ExecStart=$(which cosmovisor) run start --home "${aya_home}"
# Restart the service if it fails
Restart=always
# Restart the service after 3 seconds if it fails
RestartSec=3
# Set the maximum number of file descriptors
LimitNOFILE=4096

# Set environment variables for data backups, automatic downloading of binaries, and automatic restarts after upgrades
Environment="DAEMON_NAME=ayad"
Environment="DAEMON_HOME=${aya_home}"
Environment="DAEMON_DATA_BACKUP_DIR=${aya_home}/backup"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
# Start the service on system boot
WantedBy=multi-user.target
EOF


		sleep 5

                echo 85
                echo "# enabling the Cosmovisor service for future uses...."
		# Reload the Systemd daemon
		sudo systemctl daemon-reload
		# Enable the 'cosmovisor' service to start on system boot
		sudo systemctl enable cosmovisor
		#sudo systemctl status cosmovisor.service

		sleep 5

                echo 95
                echo "# Cleaning up...."


		#ps -ef | grep -w '/opt/aya/cosmovisor/cosmovisor'|awk '{print $2}'| kill -9
		#kill -9 $(ps -ef | grep -w '/opt/aya/cosmovisor/cosmovisor run start'|awk 'NR==1{print $2}')
		#kill -9 $(ps -ef | grep -w '/opt/aya/cosmovisor/genesis/bin/ayad start'|awk 'NR==1{print $2}')
                kill -9 $(ps -ef | grep -w "${aya_home}/cosmovisor/cosmovisor run start"|awk 'NR==1{print $2}')
                kill -9 $(ps -ef | grep -w "${aya_home}/cosmovisor/genesis/bin/ayad start"|awk 'NR==1{print $2}')
		

		sleep 5

		sudo systemctl start cosmovisor.service

		public_key=$(ayad tendermint show-validator --home /"$aya_home/")
		registration_data=$(cat "$aya_home/registration.json")

		final_msg=$(cat <<- EOM
		CONGRATULATIONS!!!!!!

		Your Validator node is now up and running. You can check the status of your validator node by using the following command:

		"sudo systemctl status cosmovisor.service"

		:-) FINAL STEPS YOU NEED TO MANUALLY (COPY THE COMMANDS BEFORE YOU HIT "OK"

		1. INSTALL CHAIN FOLLOWER SERVICE

		This can be done by going to WM Discord and download the Chainfollower service package from "public-testnet-announcements" channel. Download the package on your validator host. 

		Detailed instructions on the Github page.

		2. REGISTER YOUR NEWLY MINTED VALIDATOR IN THE AYA BLOCKCHAIN

		Go to John Kelly's guide here https://nodebasewm.github.io/docs/tutorials/validatornodemanual/ and follow from Step 30.

		Please use the following data and commands while using the steps from his guides.

		Data:
	
			$registration_data

		Command 1:

			ayad query bank balances "$operator_address" --home /opt/aya


		Command 2:

			ayad tx staking create-validator --amount=1uswmt --pubkey="$public_key" --moniker="$moniker" --chain-id="$CHAIN_ID" --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1" --from="$account" --home /opt/aya --output json --yes

		EOM
		)	
		
		zenity --info --title "Info Message" --text "$final_msg";	


		zenity --info --title "Info Message" --width 500 --height 200 --text "Incase you missed to save the data and commands, they are saved in  \n\n Command.txt file in earthnode_installer folder in the home directory";	
		echo "$final_msg">commands.txt

		echo 100
		echo "# Package Installation completed!"


		#echo "$new_val_persistent_peer"
		#echo "$new_val_unconditional_peer_ids"

	#zenity --text-info --title "Carefully review the information before proceeding" --filename "/etc/hosts"
	fi

) | zenity --width 500 --height 90 --title "Installation Progress Bar" --progress --no-cancel --auto-close


#fi
#pw=$(echo $ENTRY | cut -d'|' -f1)
                #;;
#                TMP=$(echo "${pw}" | sudo -Sv);;

