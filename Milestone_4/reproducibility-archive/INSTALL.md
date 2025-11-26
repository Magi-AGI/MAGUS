# MAGUS Installation Guide

## Prerequisites

- **Operating System**: WSL (Windows), Linux, or macOS
- **Python**: 3.12 or higher
- **Git**: For cloning repository
- **Disk Space**: ~500MB

## Step-by-Step Installation

### 1. Check Python Version

```bash
python --version  # Should be 3.12+
```

If Python 3.12+ is not installed:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.12

# macOS
brew install python@3.12
```

### 2. Create Virtual Environment

```bash
cd magus-reproducibility-v1.0/environment
python -m venv .venv
source .venv/bin/activate  # Linux/WSL/macOS
# or .venv\Scripts\activate  # Windows (if not using WSL)
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

This installs:
- `hyperon==0.2.1` (MeTTa interpreter)
- `pytest==8.0.0` (for test framework)
- `pyyaml==6.0` (for config files)
- `numpy==1.26.0` (for metrics calculations)

### 4. Verify Installation

```bash
python -c "from hyperon import MeTTa; print('Hyperon installed successfully')"
```

Expected output: `Hyperon installed successfully`

### 5. Run Smoke Test

```bash
cd ../tests
python -m pytest m4_pipeline/test_m4_pipeline.py -v
```

Expected output: `5/5 tests PASSED`

## Troubleshooting

### Issue: "hyperon: command not found"

**Solution**: Make sure virtual environment is activated:
```bash
source environment/.venv/bin/activate
```

### Issue: "Python version too old"

**Solution**: Install Python 3.12+:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.12

# macOS
brew install python@3.12
```

### Issue: "Tests fail with evaluation errors"

**Cause**: Known Hyperon 0.2.1 limitation

**Solution**: This is expected behavior documented in paper Section 4.7 and Section 5.3.3
- All functionality works
- Some display issues with complex patterns
- Workaround scripts provided (see `scripts/validate_results.py`)

### Issue: "ModuleNotFoundError: No module named 'hyperon'"

**Solution**: Virtual environment not activated or dependencies not installed:
```bash
source environment/.venv/bin/activate
pip install -r environment/requirements.txt
```

### Issue: "Permission denied" when running scripts

**Solution**: Make scripts executable:
```bash
chmod +x environment/setup.sh
chmod +x tests/run_all_tests.sh
chmod +x scripts/*.sh
```

## Windows Users

**Requirement**: WSL (Windows Subsystem for Linux)

Hyperon requires a Unix-like environment. Install WSL:

```powershell
# In PowerShell as Administrator
wsl --install
```

Then follow Linux instructions above within WSL.

## Verification Checklist

After installation, verify:

- [ ] Python 3.12+ installed and accessible
- [ ] Virtual environment created and activated
- [ ] `hyperon` package importable in Python
- [ ] `pytest` available
- [ ] Smoke test passes (5/5 tests)

If all checks pass, you're ready to run the full test suite!

## Next Steps

1. Read `tests/expected_results.md` for validation criteria
2. Run `tests/run_all_tests.sh` for full test suite
3. Use `scripts/validate_results.py` to compare outputs to baseline
4. Generate HTML report with `scripts/generate_report.py`

## Support

For issues not covered here, see:
- `docs/troubleshooting.md`
- GitHub issues (if repository is public)
- Paper authors (contact in paper)

---

**Document Version**: 1.0
**Last Updated**: October 2025
**Tested On**: Ubuntu 22.04, WSL2, macOS 14
