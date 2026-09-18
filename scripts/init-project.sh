#!/usr/bin/env bash

set -e

PROJECT_CONFIG="cmake/project-config.cmake"

if [ ! -f "$PROJECT_CONFIG" ]; then
    echo "Error: $PROJECT_CONFIG not found."
    exit 1
fi

# ------------------------------------------------------------
# Project name
# ------------------------------------------------------------

if [ -n "$1" ]; then
    PROJECT_NAME="$1"
else
    printf "Project name: "
    read -r PROJECT_NAME
fi

if [ -z "$PROJECT_NAME" ]; then
    echo "Error: project name cannot be empty."
    exit 1
fi

# ------------------------------------------------------------
# Update PROJECT_ID
# ------------------------------------------------------------

echo
echo "Initializing project: $PROJECT_NAME"

awk -v name="$PROJECT_NAME" '
{
    if ($0 ~ /^set\(PROJECT_ID /) {
        print "set(PROJECT_ID " name ")"
    } else {
        print
    }
}
' "$PROJECT_CONFIG" > "${PROJECT_CONFIG}.tmp"

mv "${PROJECT_CONFIG}.tmp" "$PROJECT_CONFIG"

# ------------------------------------------------------------
# Clean generated/local state
# ------------------------------------------------------------

rm -rf build
rm -rf .vscode
rm -f .clangd

# ------------------------------------------------------------
# IDE configuration
# ------------------------------------------------------------

echo
echo "Select IDE code intelligence:"
echo "  1) Microsoft C/C++"
echo "  2) clangd"
echo "  3) None"
echo

printf "Select [1-3]: "
read -r IDE_OPTION

case "$IDE_OPTION" in
    1)
        echo
        echo "Configuring Microsoft C/C++..."

        mkdir -p .vscode

        cp ide-templates/shared/.vscode/tasks.json .vscode/
        cp ide-templates/shared/.vscode/launch.json .vscode/
        cp ide-templates/cpp-tools/.vscode/settings.json .vscode/

        echo "Microsoft C/C++ configuration installed."
        ;;

    2)
        echo
        echo "Configuring clangd..."

        mkdir -p .vscode

        cp ide-templates/shared/.vscode/tasks.json .vscode/
        cp ide-templates/shared/.vscode/launch.json .vscode/
        cp ide-templates/clangd/.vscode/settings.json .vscode/

        if [ -f "ide-templates/clangd/.clangd" ]; then
            cp ide-templates/clangd/.clangd .
        fi

        echo "clangd configuration installed."
        ;;

    3)
        echo
        echo "Skipping IDE configuration."
        ;;

    *)
        echo
        echo "Unknown option. Skipping IDE configuration."
        ;;
esac

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

echo
echo "Project initialized successfully."
echo
echo "Next steps:"
echo "  ./scripts/stm32.sh build"
echo "  ./scripts/stm32.sh flash"