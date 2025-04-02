#!/bin/bash

# Create git hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create post-checkout hook
cat > .git/hooks/post-checkout << 'EOL'
#!/bin/bash

# Get the previous and current branch names
prev_branch=$1
curr_branch=$2
is_checkout=$3

# Only run if this is a checkout (not a file checkout)
if [ "$is_checkout" = "1" ]; then
    echo "Running build_runner after checkout..."
    ./scripts/build.sh
fi
EOL

# Make hooks executable
chmod +x .git/hooks/*

echo "Setup completed successfully!"
echo "Git hooks are now configured to run build_runner after checkouts."
