#!/bin/bash

# 🎯 Virtual environment directory name
VENV_DIR=".venv"

# 🐍 Step 1: Find a working Python 3 interpreter
find_python() {
    for candidate in python3 python "py -3"; do
        if $candidate --version &>/dev/null; then
            VERSION=$($candidate -c "import sys; print(sys.version_info.major)" 2>/dev/null)
            if [ "$VERSION" = "3" ]; then
                echo "$candidate"
                return 0
            fi
        fi
    done
    return 1
}

PYTHON_CMD=$(find_python)

if [ -z "$PYTHON_CMD" ]; then
    echo "❌ No working Python 3 interpreter found. Please install Python 3 and add it to PATH."
    return 1 2>/dev/null || exit 1
fi

echo "🔎 Using Python interpreter: $PYTHON_CMD"

# 🛠 Step 2: Create or replace virtual environment
if [ -d "$VENV_DIR" ]; then
    read -rp "⚠️ Virtual environment already exists. Do you want to replace it? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "🗑 Removing existing virtual environment..."
        rm -rf "$VENV_DIR"
        echo "✨ Creating a fresh virtual environment..."
        $PYTHON_CMD -m venv "$VENV_DIR" || { echo "❌ Failed to create venv"; return 1 2>/dev/null || exit 1; }
        echo "✅ Virtual environment recreated."
    else
        echo "➡️ Keeping existing virtual environment."
    fi
else
    echo "✨ Creating virtual environment in $PWD/$VENV_DIR ..."
    $PYTHON_CMD -m venv "$VENV_DIR" || { echo "❌ Failed to create venv"; return 1 2>/dev/null || exit 1; }
    echo "✅ Virtual environment created."
fi

# 📄 Step 3: Add virtual environment to .gitignore
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi

if ! grep -qxF "$VENV_DIR/" .gitignore; then
    echo "$VENV_DIR/" >> .gitignore
    echo "📝 Added $VENV_DIR/ to .gitignore"
else
    echo "📂 $VENV_DIR/ already in .gitignore"
fi

# 🚀 Step 4: Detect correct activate script depending on OS
# if [ -f "$VENV_DIR/bin/activate" ]; then
#     ACTIVATE="$VENV_DIR/bin/activate"   # Linux/macOS
if [ -f "$VENV_DIR/Scripts/activate" ]; then
    ACTIVATE="$VENV_DIR/Scripts/activate"   # Windows Git Bash
else
    echo "❌ Could not find activate script in $VENV_DIR"
    return 1 2>/dev/null || exit 1
fi

echo "⚡ Activating virtual environment..."
# shellcheck disable=SC1090
source "$ACTIVATE"

# 📦 Step 5: Install dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "📦 Installing dependencies from requirements.txt ..."
    pip install --upgrade pip
    pip install -r requirements.txt
    echo "✅ Dependencies installed."
else
    echo "ℹ️ No requirements.txt found. Skipping dependency installation."
fi

echo "🎉 Setup complete. Virtual environment is active."
echo "💡 You can deactivate it anytime with: deactivate"

