#!/bin/bash
# MAGUS Master Test Runner

set -e

echo "=== MAGUS Test Suite ==="
echo ""

# Ensure virtual environment is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "ERROR: Virtual environment not activated"
    echo "Run: source environment/.venv/bin/activate"
    exit 1
fi

# Track results
total_tests=0
passed_tests=0
failed_tests=0

# Run M2 measurability tests
echo "--- M2 Measurability Tests ---"
if python m2_measurability/test_measurability.py; then
    echo "✓ M2 measurability tests passed"
    passed_tests=$((passed_tests + 12))
else
    echo "✗ M2 measurability tests failed"
    failed_tests=$((failed_tests + 12))
fi
total_tests=$((total_tests + 12))
echo ""

# Run M2 correlation tests
echo "--- M2 Correlation Tests ---"
if python m2_correlation/test_correlations.py; then
    echo "✓ M2 correlation tests passed"
    passed_tests=$((passed_tests + 7))
else
    echo "✗ M2 correlation tests failed"
    failed_tests=$((failed_tests + 7))
fi
total_tests=$((total_tests + 7))
echo ""

# Run M4 pipeline tests
echo "--- M4 Pipeline Tests ---"
if python m4_pipeline/test_m4_pipeline.py; then
    echo "✓ M4 pipeline tests passed"
    passed_tests=$((passed_tests + 5))
else
    echo "✗ M4 pipeline tests failed"
    failed_tests=$((failed_tests + 5))
fi
total_tests=$((total_tests + 5))
echo ""

# Summary
echo "=== Test Summary ==="
echo "Total:  $total_tests tests"
echo "Passed: $passed_tests tests"
echo "Failed: $failed_tests tests"
echo ""

if [ $failed_tests -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
