#!/bin/bash

# exit when any command fails
set -e

# Required to suppress some git errors further down the line
if command -v git &> /dev/null; then
    git config --global --add safe.directory /home/***
fi

# Create required directory structure (if it does not already exist)
if [[ ! -d "$INVENTREE_STATIC_ROOT" ]]; then
    echo "Creating directory $INVENTREE_STATIC_ROOT"
    mkdir -p $INVENTREE_STATIC_ROOT
fi

if [[ ! -d "$INVENTREE_MEDIA_ROOT" ]]; then
    echo "Creating directory $INVENTREE_MEDIA_ROOT"
    mkdir -p $INVENTREE_MEDIA_ROOT
fi

if [[ ! -d "$INVENTREE_BACKUP_DIR" ]]; then
    echo "Creating directory $INVENTREE_BACKUP_DIR"
    mkdir -p $INVENTREE_BACKUP_DIR
fi

# Check if "config.yaml" has been copied into the correct location
if test -f "$INVENTREE_CONFIG_FILE"; then
    echo "Loading config file : $INVENTREE_CONFIG_FILE"
else
    # Wait a moment for volume mounts to be fully available (if using volumes)
    sleep 1
    
    # Try multiple possible locations for the config template
    CONFIG_TEMPLATE_PATHS=(
        "$INVENTREE_BACKEND_DIR/InvenTree/config_template.yaml"
        "${INVENTREE_HOME}/src/backend/InvenTree/config_template.yaml"
    )
    
    CONFIG_TEMPLATE=""
    for path in "${CONFIG_TEMPLATE_PATHS[@]}"; do
        if test -f "$path"; then
            CONFIG_TEMPLATE="$path"
            break
        fi
    done
    
    if [ -n "$CONFIG_TEMPLATE" ] && test -f "$CONFIG_TEMPLATE"; then
        echo "Copying config file from $CONFIG_TEMPLATE to $INVENTREE_CONFIG_FILE"
        # Ensure the config directory exists
        mkdir -p "$(dirname "$INVENTREE_CONFIG_FILE")"
        cp "$CONFIG_TEMPLATE" "$INVENTREE_CONFIG_FILE"
        echo "Config file created successfully at $INVENTREE_CONFIG_FILE"
    else
        # Don't fail - Python code will create the config file automatically if needed
        echo "Info: Config template not found. InvenTree will create config.yaml automatically on first run."
    fi
fi

# Setup a python virtual environment
# This should be done on the *mounted* filesystem,
# so that the installed modules persist!
if [[ -n "$INVENTREE_PY_ENV" ]]; then

    if test -d "$INVENTREE_PY_ENV"; then
        # venv already exists
        echo "Using Python virtual environment: ${INVENTREE_PY_ENV}"
        source ${INVENTREE_PY_ENV}/bin/activate
    else
        # Setup a virtual environment (within the provided directory)
        echo "Running first time setup for python environment"
        python3 -m venv ${INVENTREE_PY_ENV} --system-site-packages --upgrade-deps

        # Ensure invoke tool is installed locally
        source ${INVENTREE_PY_ENV}/bin/activate
        python3 -m pip install --ignore-installed --upgrade invoke
    fi

fi

cd ${INVENTREE_HOME}

# Launch the CMD *after* the ENTRYPOINT completes
exec "$@"
