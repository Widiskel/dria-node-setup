#!/bin/bash

NODENAME="dria"
GREENCOLOR="\e[32m"
DEFAULTCOLOR="\e[0m"

setup() {
    curl -s https://raw.githubusercontent.com/Widiskel/Widiskel/refs/heads/main/show_logo.sh | bash
    sleep 3

    echo "Updating & Upgrading Packages..."
    sudo apt update -y && sudo apt upgrade -y

    cd ~
    if [ -d "node" ]; then
        echo "The 'node' directory already exists."
    else
        mkdir node
        echo "Created the 'node' directory."
    fi
    cd node

    if [ -d "$NODENAME" ]; then
        echo "The '$NODENAME' directory already exists."
    else
        mkdir $NODENAME
        echo "Created the '$NODENAME' directory."
    fi
    cd $NODENAME
}


backUp(){
    pwd
    echo "Back up existing env"
    
    if [ -f ".env" ]; then
        echo ".env file already exists in the current directory, skipping backup."
    else
        if [ -f "dkn-compute-node/.env" ]; then
            cp dkn-compute-node/.env .
            echo ".env file backed up from dkn-compute-node."
        else
            echo ".env file does not exist in dkn-compute-node, skipping backup."
        fi
    fi
    
    if [ -d "dkn-compute-node" ]; then
        rm -rf dkn-compute-node
        echo "dkn-compute-node directory removed."
    else
        echo "dkn-compute-node directory does not exist, skipping removal."
    fi
    
    if [ -f "dkn-compute-node.zip" ]; then
        rm dkn-compute-node.zip
        echo "dkn-compute-node.zip file removed."
    else
        echo "dkn-compute-node.zip file does not exist, skipping removal."
    fi

    if ! command -v lsof &> /dev/null; then
        echo "lsof is not installed. Installing..."
        sudo apt-get install -y lsof
        echo "lsof installation complete."
    else
        echo "lsof is already installed."
    fi

    process_name="ollama"
    process_id=$(lsof -t -i | grep -i "$process_name")
    if [ -z "$process_id" ]; then
        echo "$process_name is not running or not using any ports."
    else
        echo "$process_name is running with PID: $process_id. Killing the process..."
        kill -9 "$process_id"
        
        if [ $? -eq 0 ]; then
            echo "$process_name process has been killed."
        else
            echo "Failed to kill $process_name process."
        fi
    fi
}



installRequirements(){
    echo "Installing $NODENAME Compute Node"
    if [ ! -d "dkn-compute-node" ] && [ ! -f "dkn-compute-node.zip" ]; then
        echo "Downloading dkn-compute-node.zip"
        ARCH=$(uname -m)

        if [ "$ARCH" == "arm64" ]; then
            echo "Architecture is arm64, downloading arm64 version."
            # for aarch64, use arm64
            curl -L -o dkn-compute-node.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-arm64.zip
        elif [ "$ARCH" == "x86_64" ]; then
            echo "Architecture is x86_64, downloading amd64 version."
            curl -L -o dkn-compute-node.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip
        else
            echo "Unknown architecture: $ARCH. Exiting."
            exit 1
        fi
        echo "Unzipping dkn-compute-node.zip"
        unzip dkn-compute-node.zip 
        rm dkn-compute-node.zip 
        cd dkn-compute-node
    else
        echo "dkn-compute-node folder already exists or dkn-compute-node.zip already downloaded."
        if [ -d "dkn-compute-node" ]; then
            cd dkn-compute-node
        fi
    fi
    echo "Copying Back Up Environment."
    cp -r ../.env .
    echo "$NODENAME Compute Node Installed"
}

finish() {
    if ! [ -f help.txt ]; then
        {
            echo "Setup Complete"
            echo "Your $NODENAME path is on ~/node/dria/"
            echo ""
            echo "Follow this guide to start your node:"
            echo "To start Your Node run ./dkn-compute-launcher"
            echo "-> Enter your DKN wallet Secret key / Private Key"
            echo "-> Before picking your models, Check the team's guide https://github.com/0xmoei/Dria-Node for Recommendations"
            echo "-> Pick a Model, recommended with Gemini + Llama3_1_8B models"
            echo "-> Get Gemini APIKEY Here https://aistudio.google.com/app/apikey"
            echo "-> Get Jina API: https://jina.ai/embeddings/ (Optional Press Enter To SKIP)"
            echo "-> Get Serper API: https://serper.dev/api-key (Optional Press Enter To SKIP)"
            echo "-> DONE. Now your node will start Downloading Model files and Testing them. Each model must pass its test, and it only depends on your system specification."
            echo ""
            echo "Useful Commands:"
            echo "- Restart your Dria Node: './dkn-compute-launcher'"
            echo "- Delete your Node: 'cd \$HOME/node/$NODENAME && rm -r dkn-compute-node'"
            echo "- If you want to see this again run 'cat ~/node/dria/dkn-compute-node/help.txt'"
        } > help.txt
    fi
    cat help.txt
}


run() {
    read -p "Do you want to run it? (y/n): " response
    if [[ $response == "y" ]]; then
        ./dkn-compute-launcher
    else
        echo "LFG"
    fi
}


setup
backUp
installRequirements
finish
run
