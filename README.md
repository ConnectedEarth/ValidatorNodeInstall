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


