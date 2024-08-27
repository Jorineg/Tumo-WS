#!/usr/bin/env bash

# Check if the input argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <GitHub Repository URL>"
    exit 1
fi

# fix code command for mac
if [[ "$(uname)" == "Darwin" ]]; then
    echo "You are on a Mac."
    # Create the directory if it doesn't exist
    mkdir -p ~/bin
    
    # Define the content of the script
    SCRIPT_CONTENT='#!/usr/bin/env bash
    
    ELECTRON="/Applications/Visual Studio Code.app/Contents/MacOS/Electron"
    CLI="/Applications/Visual Studio Code.app/Contents/Resources/app/out/cli.js"
    ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" --ms-enable-electron-run-as-node "$@"
    exit $?'
    
    # Write the script content to ~/bin/code
    echo "$SCRIPT_CONTENT" > ~/bin/code
    
    # Make the script executable
    chmod +x ~/bin/code
    
    # Add ~/bin to PATH and set alias for code
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
    source ~/.bash_profile
    echo 'alias code="$HOME/bin/code"' >> ~/.bash_profile
    source ~/.bash_profile
fi

# Clone the GitHub repository and open it in Visual Studio Code
cd ~/Desktop
git clone "$1"
cd "$(basename "$1" .git)"

# install node package
npm install vscode-websocket-alerts

code --install-extension formulahendry.code-runner --install-extension ritwickdey.LiveServer --install-extension JorinEggers.js-prompt-alert --install-extension JorinEggers.ai-code-checker
code . &

# check if second argument is provided
if [ $# -eq 2 ]; then
    echo "Setting up the AI Code Checker extension..."
    cd .vscode
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' 's/^{/{\n  "aiCodeChecker.encApiKey": "'"$2"'",/' settings.json
    else
        sed -i 's/^{/{\n  "aiCodeChecker.encApiKey": "'"$2"'",/' settings.json
    fi
    cd ..
fi
