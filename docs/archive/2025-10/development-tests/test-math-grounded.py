#!/usr/bin/env python3
"""
Test grounded math functions
"""

from hyperon import MeTTa
from pathlib import Path
import sys

# Add current directory to path so we can import math_ext
sys.path.insert(0, str(Path(__file__).parent))

import math
from hyperon import OperationAtom

def test_grounded_math():
    """Test grounded math functions work"""
    print("="*70)
    print("  GROUNDED MATH FUNCTIONS TEST")
    print("="*70)

    metta = MeTTa()

    # Manually register grounded math functions
    metta.register_atom('sqrt', OperationAtom('sqrt', lambda x: math.sqrt(x), unwrap=True))
    metta.register_atom('pow', OperationAtom('pow', lambda x, y: math.pow(x, y), unwrap=True))

    print("\n--- Registered Functions ---")
    print(f"Functions: sqrt, pow")

    # Test 1: sqrt
    print("\n--- Test 1: Square Root ---")
    result = metta.run('!(sqrt 4)')
    print(f"Input: !(sqrt 4)")
    print(f"Expected: 2.0")
    print(f"Result: {result}")

    # Test 2: sqrt of decimal
    print("\n--- Test 2: Square Root of Decimal ---")
    result = metta.run('!(sqrt 0.4032)')
    print(f"Input: !(sqrt 0.4032)")
    print(f"Expected: ~0.635")
    print(f"Result: {result}")

    # Test 3: Nested arithmetic
    print("\n--- Test 3: Nested Arithmetic ---")
    result = metta.run('!(sqrt (* 0.72 0.56))')
    print(f"Input: !(sqrt (* 0.72 0.56))")
    print(f"Expected: ~0.635")
    print(f"Result: {result}")

    # Test 4: Complex expression
    print("\n--- Test 4: Complex Expression ---")
    result = metta.run('!(* 0.7 (sqrt (* 0.72 0.56)))')
    print(f"Input: !(* 0.7 (sqrt (* 0.72 0.56)))")
    print(f"Expected: ~0.445")
    print(f"Result: {result}")

    # Test 5: pow
    print("\n--- Test 5: Power ---")
    result = metta.run('!(pow 2 3)')
    print(f"Input: !(pow 2 3)")
    print(f"Expected: 8.0")
    print(f"Result: {result}")

    # Test 6: pow fractional
    print("\n--- Test 6: Fractional Power ---")
    result = metta.run('!(pow 4 0.5)')
    print(f"Input: !(pow 4 0.5)")
    print(f"Expected: 2.0")
    print(f"Result: {result}")

if __name__ == '__main__':
    test_grounded_math()
