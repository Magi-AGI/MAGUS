"""
MeTTa Math Extension - Grounded Python Math Functions
Provides sqrt and other math operations that aren't built into Hyperon 0.2.1
"""

import math
from hyperon import OperationAtom
from hyperon.ext import register_atoms


@register_atoms()
def math_atoms():
    """Register grounded math functions"""
    return {
        'sqrt': OperationAtom('sqrt', lambda x: math.sqrt(x), unwrap=True),
        'pow': OperationAtom('pow', lambda x, y: math.pow(x, y), unwrap=True),
        'abs': OperationAtom('abs', lambda x: abs(x), unwrap=True),
        'floor': OperationAtom('floor', lambda x: math.floor(x), unwrap=True),
        'ceil': OperationAtom('ceil', lambda x: math.ceil(x), unwrap=True),
        'sin': OperationAtom('sin', lambda x: math.sin(x), unwrap=True),
        'cos': OperationAtom('cos', lambda x: math.cos(x), unwrap=True),
        'log': OperationAtom('log', lambda x: math.log(x), unwrap=True),
        'exp': OperationAtom('exp', lambda x: math.exp(x), unwrap=True),
    }
