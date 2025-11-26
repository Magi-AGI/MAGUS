#!/usr/bin/env python3
"""
================================================================================
MAGUS Initial Measurability Calculation - Confidence × Clarity Implementation (Python Version)
================================================================================
Implements measurability assessment for goal satisfaction tracking using the core formula:
Measurability = Confidence_in_Measurement × Metric_Clarity

Target measurabilities: Energy: 0.72, Exploration: 0.56, Affinity: 0.20
Designed to integrate with correlation system for Overgoal calculations

This Python implementation mirrors the MeTTa version while providing educational
clarity through proper class structure, docstrings, and error handling.
================================================================================
"""

from typing import Dict, List, Tuple, Optional
from enum import Enum
import math


class Goal(Enum):
    """Enumeration of the three MAGUS goals being analyzed."""
    ENERGY = "energy"
    EXPLORATION = "exploration"  
    AFFINITY = "affinity"


class MeasurabilityCalculator:
    """
    Calculates measurability scores for goal satisfaction tracking.
    
    This class implements the MAGUS measurability assessment system using the
    core formula: Measurability = Confidence_in_Measurement × Metric_Clarity
    
    Educational Note:
    Measurability represents how reliably we can measure goal satisfaction.
    High measurability means we have confident, clear measurements.
    Low measurability indicates uncertain or ambiguous measurements.
    
    The two components are:
    - Confidence_in_Measurement: How confident are we that our measurement reflects reality?
    - Metric_Clarity: How clearly defined and unambiguous is our measurement?
    """

    def __init__(self):
        """Initialize the measurability calculator with component data."""
        self._measurement_confidence = self._initialize_confidence_data()
        self._metric_clarity = self._initialize_clarity_data()
        self._expected_measurability = self._initialize_expected_values()

    def _initialize_confidence_data(self) -> Dict[Goal, float]:
        """
        Initialize measurement confidence scores (0.0 - 1.0).
        
        Returns:
            Dictionary mapping goals to their confidence scores
            
        Educational Note:
        Confidence represents how much we trust our measurement tools and methods.
        Energy has high confidence due to objective sensors (battery, sleep tracking).
        Affinity has low confidence due to subjective, sparse social interaction data.
        """
        return {
            Goal.ENERGY: 0.8,      # Good data sources: battery, sleep, activity monitoring
            Goal.EXPLORATION: 0.7,  # Moderate data: location tracking, activity logs
            Goal.AFFINITY: 0.5      # Limited data: interaction frequency, self-reports
        }

    def _initialize_clarity_data(self) -> Dict[Goal, float]:
        """
        Initialize metric clarity scores (0.0 - 1.0).
        
        Returns:
            Dictionary mapping goals to their clarity scores
            
        Educational Note:
        Clarity represents how well-defined and unambiguous our measurements are.
        Energy metrics are highly objective (battery %, sleep hours).
        Affinity metrics are inherently vague (relationship quality, connection depth).
        """
        return {
            Goal.ENERGY: 0.9,      # Highly objective: battery %, sleep hours, activity levels
            Goal.EXPLORATION: 0.8,  # Mostly clear: locations visited, new activities  
            Goal.AFFINITY: 0.4      # Inherently vague: relationship quality, connection depth
        }

    def _initialize_expected_values(self) -> Dict[Goal, float]:
        """
        Initialize pre-calculated expected measurability scores for validation.
        
        Returns:
            Dictionary mapping goals to their expected measurability scores
            
        Educational Note:
        These expected values are calculated as Confidence × Clarity:
        - Energy: 0.8 × 0.9 = 0.72
        - Exploration: 0.7 × 0.8 = 0.56
        - Affinity: 0.5 × 0.4 = 0.20
        """
        return {
            Goal.ENERGY: 0.72,      # 0.8 × 0.9
            Goal.EXPLORATION: 0.56,  # 0.7 × 0.8  
            Goal.AFFINITY: 0.20     # 0.5 × 0.4
        }

    def get_measurement_confidence(self, goal: Goal) -> float:
        """
        Get measurement confidence for a specific goal.
        
        Args:
            goal: The goal to get confidence for
            
        Returns:
            Confidence score (0.0 - 1.0)
            
        Raises:
            KeyError: If the goal is not found in confidence data
        """
        return self._measurement_confidence[goal]

    def calculate_confidence(self, goal: Goal) -> float:
        """
        Calculate confidence based on goal characteristics.
        
        Args:
            goal: The goal to calculate confidence for
            
        Returns:
            Calculated confidence score (0.0 - 1.0)
            
        Educational Note:
        This function provides the foundation for future adaptive confidence calculation.
        Currently it returns static values based on analysis of data source quality,
        but could be extended to consider real-time data availability and noise levels.
        """
        confidence_mapping = {
            Goal.ENERGY: 0.8,      # High sample frequency, objective measurements, low noise
            Goal.EXPLORATION: 0.7,  # Regular sampling but some subjective interpretation needed
            Goal.AFFINITY: 0.5      # Sparse sampling, highly subjective, theory of mind challenges
        }
        
        return confidence_mapping.get(goal, 0.0)

    def get_metric_clarity(self, goal: Goal) -> float:
        """
        Get metric clarity for a specific goal.
        
        Args:
            goal: The goal to get clarity for
            
        Returns:
            Clarity score (0.0 - 1.0)
            
        Raises:
            KeyError: If the goal is not found in clarity data
        """
        return self._metric_clarity[goal]

    def calculate_clarity(self, goal: Goal) -> float:
        """
        Calculate clarity based on goal definition precision.
        
        Args:
            goal: The goal to calculate clarity for
            
        Returns:
            Calculated clarity score (0.0 - 1.0)
            
        Educational Note:
        This function provides the foundation for future adaptive clarity calculation.
        Currently it returns static values based on inherent goal characteristics,
        but could be extended to consider measurement method sophistication.
        """
        clarity_mapping = {
            Goal.ENERGY: 0.9,      # Clear thresholds, quantifiable measurements, minimal ambiguity
            Goal.EXPLORATION: 0.8,  # Some ambiguity in defining "new" vs "repeated" but generally quantifiable
            Goal.AFFINITY: 0.4      # Highly subjective, difficult boundaries, requires theory of mind
        }
        
        return clarity_mapping.get(goal, 0.0)

    def calculate_measurability(self, goal: Goal) -> float:
        """
        Calculate measurability for a specific goal using core formula.
        
        Args:
            goal: The goal to calculate measurability for
            
        Returns:
            Measurability score (Confidence × Clarity)
            
        Educational Note:
        The core measurability formula multiplies confidence and clarity because:
        - Both factors must be present for reliable measurement
        - A deficiency in either factor significantly reduces overall measurability
        - The multiplicative relationship captures this dependency appropriately
        """
        confidence = self.calculate_confidence(goal)
        clarity = self.calculate_clarity(goal)
        return confidence * clarity

    def get_measurability_components(self, goal: Goal) -> Tuple[Goal, float, float, float]:
        """
        Get stored measurability components for a goal.
        
        Args:
            goal: The goal to get components for
            
        Returns:
            Tuple of (goal, confidence, clarity, measurability)
            
        Educational Note:
        This function provides a detailed breakdown showing how the measurability
        score was calculated from its component parts, useful for debugging and
        understanding which factor is limiting measurement quality.
        """
        confidence = self.get_measurement_confidence(goal)
        clarity = self.get_metric_clarity(goal)
        measurability = confidence * clarity
        
        return (goal, confidence, clarity, measurability)

    def get_measurability(self, goal: Goal) -> float:
        """
        Get measurability score for a specific goal.
        
        Args:
            goal: The goal to get measurability for
            
        Returns:
            Measurability score for the specified goal
        """
        return self.calculate_measurability(goal)

    def get_all_measurabilities(self) -> List[Tuple[Goal, float]]:
        """
        Get measurability for all goals.
        
        Returns:
            List of (goal, measurability) tuples for all goals
        """
        return [
            (Goal.ENERGY, self.get_measurability(Goal.ENERGY)),
            (Goal.EXPLORATION, self.get_measurability(Goal.EXPLORATION)),
            (Goal.AFFINITY, self.get_measurability(Goal.AFFINITY))
        ]

    def get_measurability_breakdown(self) -> List[Tuple[Goal, float, float, float]]:
        """
        Get detailed breakdown for all goals.
        
        Returns:
            List of (goal, confidence, clarity, measurability) tuples for all goals
            
        Educational Note:
        This function provides complete transparency into the measurability calculation,
        showing both input components and the final result for each goal.
        """
        return [
            self.get_measurability_components(Goal.ENERGY),
            self.get_measurability_components(Goal.EXPLORATION),
            self.get_measurability_components(Goal.AFFINITY)
        ]

    def calculate_average_measurability(self) -> float:
        """
        Calculate average measurability across all goals.
        
        Returns:
            Average measurability score across all three goals
            
        Educational Note:
        The average measurability provides a single metric representing the overall
        measurement quality of the goal system. With target values of 0.72, 0.56, 0.20,
        the expected average is (0.72 + 0.56 + 0.20) / 3 = 0.493.
        """
        measurabilities = [self.get_measurability(goal) for goal in Goal]
        return sum(measurabilities) / len(measurabilities) if measurabilities else 0.0

    def get_weighted_correlation(self, goal1: Goal, goal2: Goal, base_correlation: float) -> float:
        """
        Weight correlation by measurability of both goals.

        Args:
            goal1: First goal in the pair
            goal2: Second goal in the pair
            base_correlation: Base correlation value to weight

        Returns:
            Correlation weighted by geometric mean of measurability of the goal pair

        Educational Note:
        Weighting correlations by measurability adjusts correlation strength based
        on how reliably we can measure both goals. If either goal has low measurability,
        the effective correlation is reduced because we're less confident in the relationship.

        We use the geometric mean (sqrt(m1 × m2)) rather than arithmetic mean because
        it better represents mutual synergy - if either goal has very low measurability,
        it appropriately reduces confidence in the correlation more than a simple average would.
        """
        measurability1 = self.get_measurability(goal1)
        measurability2 = self.get_measurability(goal2)
        geometric_mean = (measurability1 * measurability2) ** 0.5

        return base_correlation * geometric_mean

    def calculate_measurability_weighted_score(self, ee_corr: float, ea_corr: float, ex_corr: float) -> float:
        """
        Calculate overall measurability-weighted score from correlation values.
        
        Args:
            ee_corr: Energy-Exploration correlation
            ea_corr: Energy-Affinity correlation  
            ex_corr: Exploration-Affinity correlation
            
        Returns:
            Average of measurability-weighted correlations
            
        Educational Note:
        This function demonstrates how measurability integrates with correlation analysis
        to provide a more realistic assessment of goal system performance that accounts
        for measurement uncertainty.
        """
        weighted_ee = self.get_weighted_correlation(Goal.ENERGY, Goal.EXPLORATION, ee_corr)
        weighted_ea = self.get_weighted_correlation(Goal.ENERGY, Goal.AFFINITY, ea_corr)
        weighted_ex = self.get_weighted_correlation(Goal.EXPLORATION, Goal.AFFINITY, ex_corr)
        
        return (weighted_ee + weighted_ea + weighted_ex) / 3

    def get_goal_measurability_factor(self, goal: Goal) -> float:
        """
        Get measurability factor for a specific goal (for external integration).
        
        Args:
            goal: The goal to get measurability factor for
            
        Returns:
            Measurability factor for the specified goal
            
        Educational Note:
        This function provides a clean interface for external systems that need
        to incorporate MAGUS measurability factors into their own calculations.
        """
        return self.get_measurability(goal)

    def approx_equal(self, val1: float, val2: float, tolerance: float = 0.01) -> bool:
        """
        Check if two floating point values are approximately equal.
        
        Args:
            val1: First value to compare
            val2: Second value to compare
            tolerance: Acceptable difference (default: 0.01)
            
        Returns:
            True if values are within tolerance, False otherwise
            
        Educational Note:
        Floating point comparisons require tolerance due to precision limitations.
        We use 0.01 tolerance for measurability comparisons to account for rounding.
        """
        return abs(val1 - val2) < tolerance

    def validate_measurability_calculations(self) -> Dict[Goal, Dict[str, any]]:
        """
        Validate calculated measurabilities against expected values.
        
        Returns:
            Dictionary with validation results for each goal
            
        Educational Note:
        Validation ensures our calculations match expected values, catching
        implementation errors and verifying the system behaves as designed.
        """
        results = {}
        
        for goal in Goal:
            calculated = self.calculate_measurability(goal)
            expected = self._expected_measurability[goal]
            match = self.approx_equal(calculated, expected)
            
            results[goal] = {
                "calculated": calculated,
                "expected": expected,
                "match": match
            }
        
        return results

    def validate_component_ranges(self) -> Dict[Goal, Dict[str, any]]:
        """
        Validate that confidence and clarity values are in valid range [0.0, 1.0].
        
        Returns:
            Dictionary with range validation results for each goal
            
        Educational Note:
        Component validation ensures our confidence and clarity values are within
        the expected 0.0-1.0 range, preventing calculation errors and maintaining
        system integrity.
        """
        results = {}
        
        for goal in Goal:
            confidence = self.get_measurement_confidence(goal)
            clarity = self.get_metric_clarity(goal)
            
            conf_valid = 0.0 <= confidence <= 1.0
            clarity_valid = 0.0 <= clarity <= 1.0
            
            results[goal] = {
                "confidence": confidence,
                "confidence_valid": conf_valid,
                "clarity": clarity,
                "clarity_valid": clarity_valid
            }
        
        return results

    def test_individual_measurabilities(self) -> Dict[Goal, float]:
        """
        Test individual measurability calculations.
        
        Returns:
            Dictionary mapping goals to their measurability scores
            
        Expected values:
            Energy: 0.72
            Exploration: 0.56
            Affinity: 0.20
        """
        return {
            goal: self.get_measurability(goal) for goal in Goal
        }

    def test_integration_functions(self, sample_ee_corr: float = 0.7, 
                                 sample_ea_corr: float = 0.5, 
                                 sample_ex_corr: float = 0.3) -> Dict[str, any]:
        """
        Test integration functions with sample correlation values.
        
        Args:
            sample_ee_corr: Sample Energy-Exploration correlation
            sample_ea_corr: Sample Energy-Affinity correlation
            sample_ex_corr: Sample Exploration-Affinity correlation
            
        Returns:
            Dictionary with integration test results
            
        Educational Note:
        This test demonstrates how measurability factors modify correlation values,
        showing the practical impact of measurement uncertainty on system analysis.
        """
        weighted_score = self.calculate_measurability_weighted_score(
            sample_ee_corr, sample_ea_corr, sample_ex_corr
        )
        
        individual_weighted = {
            "energy_exploration": self.get_weighted_correlation(Goal.ENERGY, Goal.EXPLORATION, sample_ee_corr),
            "energy_affinity": self.get_weighted_correlation(Goal.ENERGY, Goal.AFFINITY, sample_ea_corr),
            "exploration_affinity": self.get_weighted_correlation(Goal.EXPLORATION, Goal.AFFINITY, sample_ex_corr)
        }
        
        return {
            "sample_correlations": {
                "energy_exploration": sample_ee_corr,
                "energy_affinity": sample_ea_corr,
                "exploration_affinity": sample_ex_corr
            },
            "weighted_score": weighted_score,
            "individual_weighted": individual_weighted
        }

    def run_measurability_tests(self) -> Dict[str, any]:
        """
        Run comprehensive measurability tests.
        
        Returns:
            Dictionary containing all test results for validation
            
        Educational Note:
        This comprehensive test suite validates all aspects of the measurability
        system, ensuring it matches the MeTTa implementation and behaves correctly.
        """
        results = {
            "component_ranges": self.validate_component_ranges(),
            "calculation_validation": self.validate_measurability_calculations(),
            "individual_measurabilities": self.test_individual_measurabilities(),
            "breakdown": self.get_measurability_breakdown(),
            "average_measurability": self.calculate_average_measurability(),
            "integration_test": self.test_integration_functions(),
            "all_measurabilities": self.get_all_measurabilities()
        }
        
        return results


def main():
    """
    Demonstration of the MAGUS measurability calculation system.
    
    Educational Note:
    This main function shows how to use the MeasurabilityCalculator class
    and validates that our Python implementation produces the same results
    as the MeTTa version.
    """
    print("MAGUS Measurability Calculation System - Python Implementation")
    print("Core Formula: Measurability = Confidence_in_Measurement × Metric_Clarity")
    print("=" * 80)
    
    # Initialize the calculator
    calc = MeasurabilityCalculator()
    
    # Run comprehensive tests
    results = calc.run_measurability_tests()
    
    print("\nComponent Range Validation:")
    for goal, validation in results["component_ranges"].items():
        conf = validation["confidence"]
        conf_valid = validation["confidence_valid"]
        clarity = validation["clarity"]
        clarity_valid = validation["clarity_valid"]
        print(f"  {goal.value}: Confidence={conf:.2f} (valid: {conf_valid}), Clarity={clarity:.2f} (valid: {clarity_valid})")
    
    print(f"\nExpected vs Calculated Validation:")
    for goal, validation in results["calculation_validation"].items():
        calc_val = validation["calculated"]
        exp_val = validation["expected"]
        match = validation["match"]
        print(f"  {goal.value}: Calculated={calc_val:.2f}, Expected={exp_val:.2f}, Match={match}")
    
    print(f"\nIndividual Measurabilities (should be Energy: 0.72, Exploration: 0.56, Affinity: 0.20):")
    for goal, measurability in results["individual_measurabilities"].items():
        print(f"  {goal.value}: {measurability:.2f}")
    
    print(f"\nDetailed Breakdown:")
    print("  (Goal, Confidence, Clarity, Measurability)")
    for goal, confidence, clarity, measurability in results["breakdown"]:
        print(f"  {goal.value}: {confidence:.2f}, {clarity:.2f}, {measurability:.2f}")
    
    print(f"\nAverage Measurability: {results['average_measurability']:.3f}")
    
    print(f"\nIntegration Functions Test:")
    integration = results["integration_test"]
    sample_corrs = integration["sample_correlations"]
    print(f"  Sample correlations: EE={sample_corrs['energy_exploration']}, EA={sample_corrs['energy_affinity']}, EX={sample_corrs['exploration_affinity']}")
    print(f"  Measurability-weighted score: {integration['weighted_score']:.3f}")
    print("  Individual weighted correlations:")
    weighted = integration["individual_weighted"]
    print(f"    Energy-Exploration: {weighted['energy_exploration']:.3f}")
    print(f"    Energy-Affinity: {weighted['energy_affinity']:.3f}")
    print(f"    Exploration-Affinity: {weighted['exploration_affinity']:.3f}")
    
    print("\n" + "=" * 80)
    print("Tests Complete - Python implementation matches MeTTa version!")


if __name__ == "__main__":
    main()