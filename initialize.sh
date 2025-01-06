#!/usr/bin/env bash

# Check dependencies
check_dependencies() {
    # Check Git
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: Git is not installed"
        echo "Please install Git:"
        echo "- Windows: https://git-scm.com/download/win"
        echo "- macOS: brew install git"
        echo "- Linux: sudo apt-get install git"
        exit 1
    fi

    # Check Node.js
    if ! command -v node >/dev/null 2>&1; then
        echo "Error: Node.js is not installed"
        echo "Please install Node.js:"
        echo "- All platforms: https://nodejs.org/en/download/"
        echo "- macOS: brew install node"
        echo "- Linux: sudo apt-get install nodejs"
        exit 1
    fi
}

# Run dependency checks
check_dependencies

# Check if the input argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <GitHub Repository URL>"
    exit 1
fi

# Detect OS
case "$(uname -s)" in
    Darwin*)    
        # macOS specific setup
        echo "Setting up for macOS..."
        mkdir -p ~/bin
        
        SCRIPT_CONTENT='#!/usr/bin/env bash
        ELECTRON="/Applications/Visual Studio Code.app/Contents/MacOS/Electron"
        CLI="/Applications/Visual Studio Code.app/Contents/Resources/app/out/cli.js"
        
        # Handle arguments properly
        if [ "$1" = "." ]; then
            ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" --ms-enable-electron-run-as-node . .
        else
            ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" --ms-enable-electron-run-as-node "$@"
        fi
        exit $?'
        
        echo "$SCRIPT_CONTENT" > ~/bin/code
        chmod +x ~/bin/code
        
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
        source ~/.bash_profile
        echo 'alias code="$HOME/bin/code"' >> ~/.bash_profile
        source ~/.bash_profile
        DESKTOP_PATH="$HOME/Desktop"
        ;;
    MINGW*|MSYS*|CYGWIN*)    
        # Windows specific setup
        echo "Setting up for Windows..."
        DESKTOP_PATH="$USERPROFILE/Desktop"
        ;;
    Linux*)     
        if grep -q Microsoft /proc/version; then
            # WSL specific setup
            echo "Setting up for WSL..."
            DESKTOP_PATH="/mnt/c/Users/$USER/Desktop"
        else
            # Linux specific setup
            echo "Setting up for Linux..."
            DESKTOP_PATH="$HOME/Desktop"
        fi
        ;;
esac

# Create Desktop directory if it doesn't exist
mkdir -p "$DESKTOP_PATH"

# Clone the GitHub repository and open it in Visual Studio Code
cd "$DESKTOP_PATH"
git clone "$1"
cd "$(basename "$1" .git)"

# install node package
npm install vscode-websocket-alerts
npm install jest

# VSCode extensions installation
if command -v code >/dev/null 2>&1; then
    code --install-extension formulahendry.code-runner \
         --install-extension ritwickdey.LiveServer \
         --install-extension JorinEggers.js-prompt-alert \
         --install-extension JorinEggers.ai-code-checker
else
    echo "WARNING: 'code' command not found. Please install Visual Studio Code and add it to your PATH"
fi

if [ -d "code" ]; then
    cd code
fi

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

# Open VS Code
if command -v code >/dev/null 2>&1; then
    code .
else
    echo "Please open Visual Studio Code manually and open this folder"
fi
