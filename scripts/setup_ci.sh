#!/bin/bash

if [ "$1" == "enterprise" ] || [ "$1" == "testflight" ] || [ "$1" == "integrations" ]; then
    [[ $1 = "integrations" ]] && yml="$1.yml" || yml="$1-deployment.yml"

    mkdir -p .github/workflows
    
    # Copy environment file if it exists
    if [ -f "fastlane/sample.env.$1" ]; then
        cp "fastlane/sample.env.$1" "fastlane/.env.$1"
    fi
    
    # Copy workflow file if it exists
    if [ -f ".github/sample-workflows/$yml" ]; then
        cp ".github/sample-workflows/$yml" ".github/workflows/$yml"
        
        if [ "$1" != "integrations" ]; then
            echo "🟡  Configure .github/workflows/$yml and provide secrets via Github secrets if needed."
            echo "If you want to run fastlane locally, make sure that fastlane/.env.$1 is .gitignored and contains all necessary secrets"
        fi
    else
        if [ "$1" == "integrations" ]; then
            echo "💡  Integrations workflows are already set up in .github/workflows/"
        else
            echo "⚠️  Warning: .github/sample-workflows/$yml not found"
        fi
    fi
else
    echo "Provide a CI type: 'enterprise', 'testflight' or 'integrations'."
fi
