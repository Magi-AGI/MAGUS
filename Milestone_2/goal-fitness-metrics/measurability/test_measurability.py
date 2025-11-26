#!/usr/bin/env python3
"""
Test file for MAGUS measurability calculation functions - Python Implementation
================================================================================
This test module validates the Python measurability calculation implementation
against the expected target values from the MeTTa version.

Educational Note:
This test suite demonstrates comprehensive validation approaches for mathematical
systems involving floating point calculations, component validation, and
integration testing with other system components.
================================================================================
"""

import unittest
import sys
import os
from typing import Dict, List, Tuple

# Add the current directory to the path to import our module
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from initial_measurability_calculation import MeasurabilityCalculator, Goal


class TestMeasurabilityCalculations(unittest.TestCase):
    """
    Test suite for the MAGUS measurability calculation system.
    
    Educational Note:
    This test class validates all aspects of measurability calculation:
    - Individual component values (confidence, clarity)
    - Calculated measurability scores
    - Integration functions for correlation weighting
    - System validation and error handling
    """

    def setUp(self):
        """Set up test fixtures before each test method."""
        self.calculator = MeasurabilityCalculator()
        
        # Expected values from the MeTTa implementation
        self.expected_measurabilities = {
            Goal.ENERGY: 0.72,      # 0.8 × 0.9
            Goal.EXPLORATION: 0.56,  # 0.7 × 0.8
            Goal.AFFINITY: 0.20     # 0.5 × 0.4
        }
        
        self.expected_confidence = {
            Goal.ENERGY: 0.8,
            Goal.EXPLORATION: 0.7,
            Goal.AFFINITY: 0.5
        }
        
        self.expected_clarity = {
            Goal.ENERGY: 0.9,
            Goal.EXPLORATION: 0.8,
            Goal.AFFINITY: 0.4
        }
        
        # Expected average: (0.72 + 0.56 + 0.20) / 3 = 0.493333...
        self.expected_average = 0.493333

    def test_measurement_confidence_retrieval(self):
        """
        Test measurement confidence retrieval for all goals.
        
        Educational Note:
        This test validates that confidence values are correctly stored and
        retrieved, which is fundamental for the measurability calculation.
        """
        print("\n=== Measurement Confidence Tests ===")
        
        for goal, expected_conf in self.expected_confidence.items():
            actual_conf = self.calculator.get_measurement_confidence(goal)
            print(f"{goal.value} confidence: {actual_conf} (expected {expected_conf})")
            self.assertAlmostEqual(actual_conf, expected_conf, places=2)

    def test_metric_clarity_retrieval(self):
        """
        Test metric clarity retrieval for all goals.
        
        Educational Note:
        This test validates that clarity values are correctly stored and
        retrieved, ensuring the second component of measurability calculation works.
        """
        print("\n=== Metric Clarity Tests ===")
        
        for goal, expected_clarity in self.expected_clarity.items():
            actual_clarity = self.calculator.get_metric_clarity(goal)
            print(f"{goal.value} clarity: {actual_clarity} (expected {expected_clarity})")
            self.assertAlmostEqual(actual_clarity, expected_clarity, places=2)

    def test_individual_measurability_calculations(self):
        """
        Test individual measurability calculations against target values.
        
        Educational Note:
        This is the core test that validates the Confidence × Clarity formula
        produces the expected results for each goal type.
        """
        print("\n=== Individual Measurability Tests ===")
        
        for goal, expected_meas in self.expected_measurabilities.items():
            actual_meas = self.calculator.get_measurability(goal)
            print(f"{goal.value} measurability: {actual_meas:.3f} (expected {expected_meas})")
            self.assertAlmostEqual(actual_meas, expected_meas, places=2)

    def test_measurability_components_breakdown(self):
        """
        Test detailed measurability component breakdown.
        
        Educational Note:
        This test validates that the component breakdown function correctly
        returns all parts of the measurability calculation, which is crucial
        for debugging and understanding system behavior.
        """
        print("\n=== Measurability Component Breakdown Tests ===")
        
        for goal in Goal:
            result_goal, confidence, clarity, measurability = self.calculator.get_measurability_components(goal)
            
            # Validate structure
            self.assertEqual(result_goal, goal)
            self.assertIsInstance(confidence, float)
            self.assertIsInstance(clarity, float)
            self.assertIsInstance(measurability, float)
            
            # Validate values
            self.assertAlmostEqual(confidence, self.expected_confidence[goal], places=2)
            self.assertAlmostEqual(clarity, self.expected_clarity[goal], places=2)
            self.assertAlmostEqual(measurability, self.expected_measurabilities[goal], places=2)
            
            # Validate calculation: measurability should equal confidence × clarity
            expected_calc = confidence * clarity
            self.assertAlmostEqual(measurability, expected_calc, places=3)
            
            print(f"{goal.value}: conf={confidence}, clarity={clarity}, meas={measurability:.3f}")

    def test_all_measurabilities_function(self):
        """
        Test the get_all_measurabilities function.
        
        Educational Note:
        This test validates that the bulk measurability retrieval function
        returns the correct structure and values for downstream processing.
        """
        print("\n=== All Measurabilities Function Test ===")
        
        all_measurabilities = self.calculator.get_all_measurabilities()
        
        # Verify structure: list of (goal, measurability) tuples
        self.assertEqual(len(all_measurabilities), 3)
        
        for goal, measurability in all_measurabilities:
            self.assertIsInstance(goal, Goal)
            self.assertIsInstance(measurability, float)
            
            # Verify values match expected
            expected = self.expected_measurabilities[goal]
            self.assertAlmostEqual(measurability, expected, places=2)
            print(f"{goal.value}: {measurability:.3f}")

    def test_average_measurability_calculation(self):
        """
        Test average measurability calculation.
        
        Educational Note:
        The average measurability provides a single metric representing
        overall measurement quality across the goal system.
        """
        print("\n=== Average Measurability Test ===")
        
        avg_measurability = self.calculator.calculate_average_measurability()
        print(f"Average measurability: {avg_measurability:.6f} (expected ~{self.expected_average:.6f})")
        
        self.assertAlmostEqual(avg_measurability, self.expected_average, places=3)
        
        # Manual verification
        manual_avg = sum(self.expected_measurabilities.values()) / len(self.expected_measurabilities)
        print(f"Manual calculation: {manual_avg:.6f}")
        self.assertAlmostEqual(avg_measurability, manual_avg, places=6)

    def test_component_range_validation(self):
        """
        Test that confidence and clarity values are in valid range [0.0, 1.0].
        
        Educational Note:
        Range validation is critical for ensuring data integrity and preventing
        calculation errors that could propagate through the system.
        """
        print("\n=== Component Range Validation Test ===")
        
        validation_results = self.calculator.validate_component_ranges()
        
        for goal, results in validation_results.items():
            confidence = results["confidence"]
            clarity = results["clarity"]
            conf_valid = results["confidence_valid"]
            clarity_valid = results["clarity_valid"]
            
            print(f"{goal.value}: conf={confidence:.2f} (valid: {conf_valid}), clarity={clarity:.2f} (valid: {clarity_valid})")
            
            # Validate ranges
            self.assertTrue(conf_valid, f"Confidence for {goal.value} out of range: {confidence}")
            self.assertTrue(clarity_valid, f"Clarity for {goal.value} out of range: {clarity}")
            
            # Double-check manually
            self.assertTrue(0.0 <= confidence <= 1.0)
            self.assertTrue(0.0 <= clarity <= 1.0)

    def test_calculation_validation(self):
        """
        Test validation of calculated values against expected values.
        
        Educational Note:
        This test ensures our calculation logic matches the expected behavior
        defined in the system specification.
        """
        print("\n=== Calculation Validation Test ===")
        
        validation_results = self.calculator.validate_measurability_calculations()
        
        for goal, results in validation_results.items():
            calculated = results["calculated"]
            expected = results["expected"]
            match = results["match"]
            
            print(f"{goal.value}: calc={calculated:.3f}, exp={expected:.3f}, match={match}")
            
            self.assertTrue(match, f"Calculated value {calculated} doesn't match expected {expected} for {goal.value}")
            self.assertAlmostEqual(calculated, expected, places=2)

    def test_weighted_correlation_integration(self):
        """
        Test integration with correlation system through weighted correlation calculation.
        
        Educational Note:
        This test validates that measurability correctly modifies correlation values,
        which is essential for the integrated MAGUS goal analysis system.
        """
        print("\n=== Weighted Correlation Integration Test ===")
        
        # Test with sample correlation values from the correlation system
        test_cases = [
            (Goal.ENERGY, Goal.EXPLORATION, 0.7),
            (Goal.ENERGY, Goal.AFFINITY, 0.5),
            (Goal.EXPLORATION, Goal.AFFINITY, 0.3)
        ]
        
        for goal1, goal2, base_corr in test_cases:
            weighted_corr = self.calculator.get_weighted_correlation(goal1, goal2, base_corr)

            # Calculate expected weighted correlation manually using geometric mean
            meas1 = self.calculator.get_measurability(goal1)
            meas2 = self.calculator.get_measurability(goal2)
            geometric_mean = (meas1 * meas2) ** 0.5
            expected_weighted = base_corr * geometric_mean

            print(f"{goal1.value}-{goal2.value}: base={base_corr}, weighted={weighted_corr:.4f}, expected={expected_weighted:.4f}")

            self.assertAlmostEqual(weighted_corr, expected_weighted, places=4)
            
            # Weighted correlation should be less than or equal to base correlation
            # (since all measurability values are ≤ 1.0)
            self.assertLessEqual(weighted_corr, base_corr)

    def test_measurability_weighted_score(self):
        """
        Test overall measurability-weighted score calculation.
        
        Educational Note:
        This test validates the integration function that combines multiple
        weighted correlations into a single score, demonstrating how measurability
        affects overall system assessment.
        """
        print("\n=== Measurability-Weighted Score Test ===")
        
        # Use standard correlation values
        ee_corr, ea_corr, ex_corr = 0.7, 0.5, 0.3
        
        weighted_score = self.calculator.calculate_measurability_weighted_score(ee_corr, ea_corr, ex_corr)
        
        # Calculate expected score manually
        weighted_ee = self.calculator.get_weighted_correlation(Goal.ENERGY, Goal.EXPLORATION, ee_corr)
        weighted_ea = self.calculator.get_weighted_correlation(Goal.ENERGY, Goal.AFFINITY, ea_corr)
        weighted_ex = self.calculator.get_weighted_correlation(Goal.EXPLORATION, Goal.AFFINITY, ex_corr)
        
        expected_score = (weighted_ee + weighted_ea + weighted_ex) / 3
        
        print(f"Input correlations: EE={ee_corr}, EA={ea_corr}, EX={ex_corr}")
        print(f"Weighted correlations: EE={weighted_ee:.4f}, EA={weighted_ea:.4f}, EX={weighted_ex:.4f}")
        print(f"Weighted score: {weighted_score:.4f}, expected: {expected_score:.4f}")
        
        self.assertAlmostEqual(weighted_score, expected_score, places=4)

    def test_comprehensive_system(self):
        """
        Run the comprehensive test suite that mirrors the MeTTa run_measurability_tests function.
        
        Educational Note:
        This test replicates the full test suite from the MeTTa implementation,
        ensuring our Python version behaves identically to the original.
        """
        print("\n=== Comprehensive System Test ===")
        
        results = self.calculator.run_measurability_tests()
        
        # Validate the results structure
        expected_keys = [
            "component_ranges", "calculation_validation", "individual_measurabilities",
            "breakdown", "average_measurability", "integration_test", "all_measurabilities"
        ]
        
        for key in expected_keys:
            self.assertIn(key, results, f"Missing key in results: {key}")
        
        # Validate individual measurabilities
        individual = results["individual_measurabilities"]
        for goal, expected in self.expected_measurabilities.items():
            self.assertAlmostEqual(individual[goal], expected, places=2)
        
        # Validate average measurability
        self.assertAlmostEqual(results["average_measurability"], self.expected_average, places=3)
        
        print("Comprehensive system test passed!")

    def test_approx_equal_function(self):
        """
        Test the approximate equality function used for floating point comparisons.
        
        Educational Note:
        Floating point comparison testing is important because it validates
        the tolerance mechanism used throughout the measurability system.
        """
        print("\n=== Approximate Equality Function Test ===")
        
        # Test cases: (val1, val2, expected_result, description)
        test_cases = [
            (0.72, 0.72, True, "identical values"),
            (0.72, 0.725, True, "within default tolerance"),
            (0.72, 0.731, False, "outside default tolerance"),
            (0.5, 0.505, True, "small difference within tolerance"),
            (0.5, 0.52, False, "larger difference outside tolerance")
        ]
        
        for val1, val2, expected, description in test_cases:
            result = self.calculator.approx_equal(val1, val2)
            print(f"{description}: approx_equal({val1}, {val2}) = {result} (expected {expected})")
            self.assertEqual(result, expected)
            
        # Test custom tolerance
        result_custom = self.calculator.approx_equal(0.72, 0.731, tolerance=0.02)
        print(f"Custom tolerance test: approx_equal(0.72, 0.731, tolerance=0.02) = {result_custom}")
        self.assertTrue(result_custom)


def run_manual_tests():
    """
    Run manual tests that mirror the MeTTa test structure.
    
    Educational Note:
    This function provides a more direct translation of the MeTTa test
    approach, showing how the Python implementation produces identical
    output to the original MeTTa version.
    """
    print("=" * 80)
    print("MAGUS Measurability System - Manual Test Suite")
    print("Core Formula: Measurability = Confidence_in_Measurement × Metric_Clarity")
    print("=" * 80)
    
    calculator = MeasurabilityCalculator()
    
    # Run comprehensive tests (mirrors MeTTa run_measurability_tests)
    results = calculator.run_measurability_tests()
    
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
    
    print(f"\nDetailed Breakdown (Goal, Confidence, Clarity, Measurability):")
    for goal, confidence, clarity, measurability in results["breakdown"]:
        print(f"  {goal.value}: {confidence:.2f}, {clarity:.2f}, {measurability:.2f}")
    
    print(f"\nAverage Measurability: {results['average_measurability']:.6f}")
    
    print(f"\nIntegration Functions Test:")
    integration = results["integration_test"]
    sample_corrs = integration["sample_correlations"]
    print(f"  Sample correlation values: {sample_corrs['energy_exploration']}, {sample_corrs['energy_affinity']}, {sample_corrs['exploration_affinity']}")
    print(f"  Measurability-weighted score: {integration['weighted_score']:.6f}")
    print("  Individual weighted correlations:")
    weighted = integration["individual_weighted"]
    print(f"    Energy-Exploration: {weighted['energy_exploration']:.6f}")
    print(f"    Energy-Affinity: {weighted['energy_affinity']:.6f}")
    print(f"    Exploration-Affinity: {weighted['exploration_affinity']:.6f}")
    
    print(f"\nAll Measurabilities Summary:")
    for goal, measurability in results["all_measurabilities"]:
        print(f"  {goal.value}: {measurability:.2f}")


if __name__ == "__main__":
    # Run manual tests first (mirroring MeTTa output)
    run_manual_tests()
    
    # Then run the formal unit tests
    print("\n" + "=" * 80)
    print("Running Unit Tests...")
    print("=" * 80)
    unittest.main(verbosity=2)