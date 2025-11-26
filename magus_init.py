"""
MAGUS Initialization Module

Provides standard initialization for MAGUS systems including:
- Grounded Python math functions (sqrt, pow, etc.)
- Optional module loading helpers
- Standard configuration

Usage:
    from magus_init import initialize_magus
    from hyperon import MeTTa

    metta = initialize_magus(MeTTa())
    # Now metta has all grounded functions registered

Or:
    from magus_init import initialize_magus
    metta = initialize_magus()  # Creates new MeTTa instance
"""

import math
from hyperon import MeTTa, OperationAtom
from pathlib import Path


def register_grounded_math(metta):
    """
    Register grounded Python math functions with MeTTa

    Args:
        metta: MeTTa instance

    Returns:
        Same MeTTa instance (for chaining)

    Registered Functions:
        - sqrt: Square root
        - pow: Power (x^y)
        - abs: Absolute value
        - floor: Floor function
        - ceil: Ceiling function
        - sin, cos: Trigonometric functions
        - log, exp: Logarithm and exponential
    """
    grounded_functions = {
        'sqrt': lambda x: math.sqrt(x),
        'pow': lambda x, y: math.pow(x, y),
        'abs': lambda x: abs(x),
        'floor': lambda x: math.floor(x),
        'ceil': lambda x: math.ceil(x),
        'sin': lambda x: math.sin(x),
        'cos': lambda x: math.cos(x),
        'log': lambda x: math.log(x),
        'exp': lambda x: math.exp(x),
    }

    for name, func in grounded_functions.items():
        metta.register_atom(name, OperationAtom(name, func, unwrap=True))

    return metta


def load_magus_core(metta, base_dir=None):
    """
    Load MAGUS core modules

    Args:
        metta: MeTTa instance
        base_dir: Base directory for MAGUS modules (defaults to current file's parent)

    Returns:
        Same MeTTa instance (for chaining)

    Loads:
        - types.metta
        - math-grounded.metta (type declarations)
    """
    if base_dir is None:
        base_dir = Path(__file__).parent

    # Load types
    types_path = base_dir / 'types.metta'
    if types_path.exists():
        with open(types_path, 'r', encoding='utf-8') as f:
            metta.run(f.read())

    # Load math grounded type declarations
    math_grounded_path = base_dir / 'math-grounded.metta'
    if math_grounded_path.exists():
        with open(math_grounded_path, 'r', encoding='utf-8') as f:
            metta.run(f.read())

    return metta


def initialize_magus(metta=None, load_core=False, base_dir=None):
    """
    Initialize MAGUS system with all required components

    Args:
        metta: MeTTa instance (creates new one if None)
        load_core: Whether to load core modules (default: False)
        base_dir: Base directory for modules (defaults to current file's parent)

    Returns:
        Initialized MeTTa instance

    Example:
        # Minimal initialization (just grounded functions)
        metta = initialize_magus()

        # Full initialization with core modules
        metta = initialize_magus(load_core=True)

        # Initialize existing instance
        metta = initialize_magus(my_metta, load_core=True)
    """
    if metta is None:
        metta = MeTTa()

    # Always register grounded math functions
    register_grounded_math(metta)

    # Optionally load core modules
    if load_core:
        load_magus_core(metta, base_dir)

    return metta


# Convenience function for common use case
def quick_init():
    """
    Quick initialization with core modules loaded

    Returns:
        Initialized MeTTa instance with core modules

    Example:
        from magus_init import quick_init
        metta = quick_init()
    """
    return initialize_magus(load_core=True)


if __name__ == '__main__':
    # Test the initialization
    print("="*70)
    print("  MAGUS Initialization Test")
    print("="*70)

    metta = initialize_magus()

    print("\nTesting grounded math functions:")
    print(f"  sqrt(4) = {metta.run('!(sqrt 4)')}")
    print(f"  pow(2, 3) = {metta.run('!(pow 2 3)')}")
    print(f"  sqrt(0.4032) = {metta.run('!(sqrt 0.4032)')}")

    print("\n✓ Initialization successful!")
    print("\nUsage:")
    print("  from magus_init import initialize_magus")
    print("  metta = initialize_magus()")
