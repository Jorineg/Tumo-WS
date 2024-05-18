#!/usr/bin/env bash

# Check if the input argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <GitHub Repository URL>"
    exit 1
fi

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

# install node package
npm install vscode-websocket-alerts

# Clone the GitHub repository and open it in Visual Studio Code
cd ~/Desktop
git clone "$1"
cd "$(basename "$1" .git)"
code --install-extension formulahendry.code-runner --install-extension ritwickdey.LiveServer && --install-extension JorinEggers.js-prompt-alert
code .
