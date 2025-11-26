#!/bin/bash
# MAGUS Reproducibility Environment Setup Script

set -e  # Exit on error

echo "=== MAGUS Reproducibility Environment Setup ==="
echo ""

# Check Python version
echo "Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
required_version="3.12"

# Version comparison (simple check for 3.12+)
major_minor=$(echo "$python_version" | cut -d. -f1,2)
if [ "$(printf '%s\n' "$required_version" "$major_minor" | sort -V | head -n1)" != "$required_version" ]; then
    echo "ERROR: Python $required_version or higher required (found $python_version)"
    exit 1
fi

echo "✓ Python $python_version detected"
echo ""

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv .venv

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip --quiet

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt --quiet

# Verify installation
echo ""
echo "Verifying installation..."
python3 -c "from hyperon import MeTTa; print('✓ Hyperon installed')"
python3 -c "import pytest; print('✓ pytest installed')"
python3 -c "import yaml; print('✓ pyyaml installed')"
python3 -c "import numpy; print('✓ numpy installed')"

echo ""
echo "=== Setup Complete ==="
echo "To activate environment:"
echo "  source environment/.venv/bin/activate"
echo ""
echo "To run tests:"
echo "  cd tests && ./run_all_tests.sh"
