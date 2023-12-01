# ValidatorNodeInstall
Disclaimer: No warranty, please use at your own risk. 

Video Guide:

This script is based on John Kelly's and Nico Vervoben's  work that can be found here:
  
      https://nodebasewm.github.io/docs/tutorials/validatornodemanual/

It is highly recommened that user of this script should go through above guide to understand the innerworking of the installation script.

This script is built on Ubantu linux 22.04 LTS. 

**Pre-requisites**

It is highly recommended that following information is gathered before starting the installation. Following information will be asked during the installation.
1. Aya installation directory location
2. Moniker account name
3. Operator account name
4. Keyring password
5. number of Sentry nodes that is needed to bootstrap the validator node (Minimum 2)
6. Sentry node host machine IPs, User IDs,Passwords and Aya installation directory at each Sentry nodes (This will be asked for each Sentry nodes)
7. Depending on your setup, if existing Sentry nodes are already hooked up to Validator nodes, then Script will ask to make a decision based on your situation
8. Firewall related questions.

During the installation, if installation script fails due to user error (wrong IP or password entered), there is nothing to fear. You can restart your installation from the beginnintg. Proper pre-cuations are taken in the code to rollback changes if any made to existing Sentry Nodes.

Installation script needs a stable internet connection between your client machine and remote server.

For this script to work, a X11 server is necessary to be running on client machine.

**Windows Client (Tested)**

1. Download X11 Server that can be found here:

        https://mobaxterm.mobatek.net/download-home-edition.html

2. Once downloaded, open up a SSH session to the server where WM Vaidator node will be installed.

        ssh <UserName>@xxx.xxx.xxx.xxx

3. Once logged in, execute the following command

        sudo apt install unzip
        wget https://github.com/ConnectedEarth/ValidatorNodeInstall/archive/refs/heads/main.zip
        unzip main.zip
        rm main.zip
        cd ValidatorNodeInstall-main/
   
5. Give execution permision to the file and then execute the file

       chmod +x install_WM_sentry_v1.sh
       ./install_WM_sentry_v1.sh

6. **If you are getting an error "cant open display", try following on your remote server:**

       sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=0
       exit
       ssh <UserName>@xxx.xxx.xxx.xxx
       cd SentryNodeInstall-main/
       ./install_WM_Validator_v1.sh
  Explanation: Xserver system needs IpV6 enabled on lo interface. I found it to be disabled by       default on Contabo virtual machines. This will lead to absence of .Xauthority file which will      inturn cause an error "cant open display".

7. Once the installation is complete, check whether node is running fine or not.
   This can be done in two ways:
   
   a.using the following command

       sudo systemctl status cosmovisor.service
   
   b. By installing Ayaviw (Created and maintained by Nico Vervoben) 
   
        cd ~/
        mkdir nodebase-tools 
        cd nodebase-tools
        wget -O ayaview.zip https://github.com/nodebasewm/download/blob/main/ayaview.zip?raw=true
        unzip ayaview.zip
        rm ayaview.zip
       ./ayaview

7. ***IMPORTANT***:Once Validaror node is installed, 

   a. INSTALL CHAIN FOLLOWER SERVICE

    This can be done by going to WM Discord and downloading the Chainfollower service package from "public-testnet-announcements" channel. Download the package on your validator host. 
    
    b. REGISTER YOUR NEWLY MINTED VALIDATOR IN THE AYA BLOCKCHAIN
    1. go to "<your home directory>/earthnode_installer" and open the file "commands.txt". you will need those commands and data to register the validator node into the Aya blockchain.
    2. Go to John Kelly's guide here https://nodebasewm.github.io/docs/tutorials/validatornodemanual/ and follow from Step 30.
