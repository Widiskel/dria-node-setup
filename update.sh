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
    echo "Back up existing env"
    
    if [ -f "dkn-compute-node/.env" ]; then
        cp dkn-compute-node/.env .
        echo ".env file backed up."
    else
        echo ".env file does not exist, skipping backup."
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
}



installRequirements(){
    echo "Installing $NODENAME Compute Node"
    if [ ! -d "dkn-compute-node" ] && [ ! -f "dkn-compute-node.zip" ]; then
        echo "Downloading dkn-compute-node.zip"
        curl -L -o dkn-compute-node.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-macOS-arm64.zip
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
