"""
Shared Test Fixtures for MAGUS Integration Tests

Provides common setup, expected values, and utility functions to reduce
duplication across integration tests.
"""

from pathlib import Path
from typing import Tuple, Dict, TYPE_CHECKING

if TYPE_CHECKING:
    from hyperon import MeTTa


# =============================================================================
# Expected Values (Source of Truth)
# =============================================================================

EXPECTED_MEASURABILITIES = {
    'energy': 0.72,
    'exploration': 0.56,
    'affinity': 0.20
}

EXPECTED_BASE_CORRELATIONS = {
    ('energy', 'exploration'): 0.70,
    ('energy', 'affinity'): 0.50,
    ('exploration', 'affinity'): 0.30
}

EXPECTED_WEIGHTED_CORRELATIONS = {
    ('energy', 'exploration'): 0.4445,  # 0.7 × sqrt(0.72 × 0.56)
    ('energy', 'affinity'): 0.1897,     # 0.5 × sqrt(0.72 × 0.20)
    ('exploration', 'affinity'): 0.1004  # 0.3 × sqrt(0.56 × 0.20)
}

EXPECTED_OVERGOAL_BONUS = 0.095  # 0.3 × avg(0.4445, 0.1897) = 0.3 × 0.318


# =============================================================================
# Setup Functions
# =============================================================================

def setup_magus_with_m2() -> Tuple['MeTTa', Path]:
    """
    Initialize MAGUS with M2 measurability and correlation modules loaded.

    Returns:
        tuple: (initialized MeTTa instance, base directory path)
    """
    from magus_init import initialize_magus
    metta = initialize_magus()
    base_dir = Path(__file__).parent

    # Load M2 modules
    m2_modules = [
        base_dir / 'types.metta',
        base_dir / 'Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta',
        base_dir / 'Milestone_2/goal-fitness-metrics/correlation/initial_correlation_calculation.metta',
    ]

    for module in m2_modules:
        if not module.exists():
            raise FileNotFoundError(f"Missing module: {module}")
        with open(module, 'r', encoding='utf-8') as f:
            metta.run(f.read())

    return metta, base_dir


def setup_magus_with_m2_m3() -> Tuple['MeTTa', Path]:
    """
    Initialize MAGUS with M2 and M3 modules loaded.

    Returns:
        tuple: (initialized MeTTa instance, base directory path)
    """
    metta, base_dir = setup_magus_with_m2()

    # Load M3 modules
    m3_modules = [
        base_dir / 'Milestone_3/core/metagoals.metta',
        base_dir / 'Milestone_3/core/antigoals.metta',
        base_dir / 'Milestone_3/core/overgoal.metta',
        base_dir / 'Milestone_3/core/scoring-v2.metta',
    ]

    for module in m3_modules:
        if not module.exists():
            raise FileNotFoundError(f"Missing module: {module}")
        with open(module, 'r', encoding='utf-8') as f:
            metta.run(f.read())

    return metta, base_dir


# =============================================================================
# Validation Functions
# =============================================================================

def get_metta_number(metta: 'MeTTa', expr: str) -> float:
    """
    Execute MeTTa expression and extract numeric result.

    Args:
        metta: MeTTa instance
        expr: Expression to evaluate

    Returns:
        float: Numeric result

    Raises:
        AssertionError: If expression returns no value or non-numeric value
    """
    result = metta.run(expr.strip())
    if not result:
        raise AssertionError(f"Expression returned no values: {expr}")

    value = result[0]
    if isinstance(value, list):
        if not value:
            raise AssertionError(f"Expression returned empty list: {expr}")
        value = value[0]

    if hasattr(value, 'get_object'):
        value = value.get_object()
    if hasattr(value, 'value'):
        value = value.value

    try:
        return float(value)
    except Exception as exc:
        raise AssertionError(f"Could not convert result to float: {value}") from exc


def validate_measurability(metta: 'MeTTa', goal: str, tolerance: float = 0.01) -> None:
    """
    Validate measurability value for a goal.

    Args:
        metta: MeTTa instance with M2 loaded
        goal: Goal name (energy, exploration, affinity)
        tolerance: Acceptable deviation from expected value

    Raises:
        AssertionError: If measurability outside tolerance
    """
    expected = EXPECTED_MEASURABILITIES[goal]
    actual = get_metta_number(metta, f'!(get-measurability {goal})')

    if abs(actual - expected) > tolerance:
        raise AssertionError(
            f"{goal} measurability mismatch: expected {expected}, got {actual}"
        )


def validate_correlation(metta: 'MeTTa', goal1: str, goal2: str, tolerance: float = 0.01) -> None:
    """
    Validate correlation value between two goals.

    Args:
        metta: MeTTa instance with M2 loaded
        goal1: First goal name
        goal2: Second goal name
        tolerance: Acceptable deviation from expected value

    Raises:
        AssertionError: If correlation outside tolerance
    """
    key = tuple(sorted([goal1, goal2]))
    if key not in EXPECTED_BASE_CORRELATIONS:
        key = (goal2, goal1)

    expected = EXPECTED_BASE_CORRELATIONS[key]
    actual = get_metta_number(metta, f'!(get-correlation {goal1} {goal2})')

    if abs(actual - expected) > tolerance:
        raise AssertionError(
            f"{goal1}-{goal2} correlation mismatch: expected {expected}, got {actual}"
        )


def validate_weighted_correlation(
    metta: 'MeTTa',
    goal1: str,
    goal2: str,
    base_corr: float,
    tolerance: float = 0.01
) -> None:
    """
    Validate weighted correlation calculation.

    Args:
        metta: MeTTa instance with M2 loaded
        goal1: First goal name
        goal2: Second goal name
        base_corr: Base correlation value
        tolerance: Acceptable deviation

    Raises:
        AssertionError: If weighted correlation outside tolerance
    """
    key = tuple(sorted([goal1, goal2]))
    if key not in EXPECTED_WEIGHTED_CORRELATIONS:
        key = (goal2, goal1)

    expected = EXPECTED_WEIGHTED_CORRELATIONS[key]
    actual = get_metta_number(
        metta,
        f'!(get-weighted-correlation {goal1} {goal2} {base_corr})'
    )

    if abs(actual - expected) > tolerance:
        raise AssertionError(
            f"{goal1}-{goal2} weighted correlation mismatch: expected {expected}, got {actual}"
        )


def validate_overgoal_bonus(actual: float, tolerance: float = 0.015) -> None:
    """
    Validate overgoal bonus is in expected range.

    Args:
        actual: Calculated overgoal bonus
        tolerance: Acceptable deviation from expected

    Raises:
        AssertionError: If bonus outside tolerance
    """
    expected = EXPECTED_OVERGOAL_BONUS

    if abs(actual - expected) > tolerance:
        raise AssertionError(
            f"Overgoal bonus mismatch: expected {expected}, got {actual}"
        )


# =============================================================================
# Utility Functions
# =============================================================================

def print_section(title: str) -> None:
    """Print formatted section header."""
    print(f"\n{'='*70}")
    print(f"  {title}")
    print('='*70)


def assert_nonempty(result) -> None:
    """Assert MeTTa result is non-empty."""
    if not result:
        raise AssertionError("Expected non-empty result")


# =============================================================================
# Test Data Structures
# =============================================================================

def get_test_context() -> Dict:
    """
    Get standard test context with goals, modulators, and resources.

    Returns:
        dict: Test context data
    """
    return {
        'goals': [
            ('goal', 'energy', 0.9, 0.8),
            ('goal', 'exploration', 0.6, 0.5),
            ('goal', 'affinity', 0.3, 0.2),
        ],
        'modulators': [
            ('modulator', 'arousal', 0.8),
            ('modulator', 'pleasure', 0.7),
            ('modulator', 'dominance', 0.6),
            ('modulator', 'focus', 0.9),
            ('modulator', 'resolution', 0.8),
            ('modulator', 'exteroception', 0.7),
        ],
        'resources': {
            'energy_level': 1000,
            'timestamp': 1000,
        }
    }


# =============================================================================
# Module Information
# =============================================================================

__all__ = [
    # Expected values
    'EXPECTED_MEASURABILITIES',
    'EXPECTED_BASE_CORRELATIONS',
    'EXPECTED_WEIGHTED_CORRELATIONS',
    'EXPECTED_OVERGOAL_BONUS',

    # Setup functions
    'setup_magus_with_m2',
    'setup_magus_with_m2_m3',

    # Validation functions
    'get_metta_number',
    'validate_measurability',
    'validate_correlation',
    'validate_weighted_correlation',
    'validate_overgoal_bonus',

    # Utility functions
    'print_section',
    'assert_nonempty',

    # Test data
    'get_test_context',
]
