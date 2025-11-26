#!/usr/bin/env python3
"""
Test file for MAGUS MIC correlation functions - Python Implementation
================================================================================
This test module validates the Python correlation calculation implementation
against the expected target values from the MeTTa version.

Educational Note:
Testing is crucial in any software system, especially for mathematical
computations where precision matters. This file demonstrates proper test
organization and validation approaches for correlation analysis systems.
================================================================================
"""

import unittest
import sys
import os
from typing import Dict, List, Tuple

# Add the current directory to the path to import our module
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from initial_correlation_calculation import CorrelationCalculator, Goal


class TestCorrelationCalculations(unittest.TestCase):
    """
    Test suite for the MAGUS correlation calculation system.
    
    Educational Note:
    This class uses Python's unittest framework to organize and run tests.
    Each test method validates a specific aspect of the correlation system,
    ensuring our implementation matches the expected MeTTa behavior.
    """

    def setUp(self):
        """Set up test fixtures before each test method."""
        self.calculator = CorrelationCalculator()
        
        # Expected values from the MeTTa implementation
        self.expected_correlations = {
            "energy_exploration": 0.70,
            "energy_affinity": 0.50,
            "exploration_affinity": 0.30
        }
        
        self.expected_total_score = 0.50  # (0.7 + 0.5 + 0.3) / 3

    def test_individual_correlations(self):
        """
        Test individual correlation retrieval against target values.
        
        Educational Note:
        This test validates that our Python implementation produces the exact
        same correlation values as the MeTTa version for each goal pair.
        """
        print("\n=== Individual Correlation Tests ===")
        
        # Test Energy-Exploration correlation
        ee_corr = self.calculator.get_correlation(Goal.ENERGY, Goal.EXPLORATION)
        print(f"Energy-Exploration: {ee_corr}")
        self.assertAlmostEqual(ee_corr, self.expected_correlations["energy_exploration"], places=2)
        
        # Test Energy-Affinity correlation  
        ea_corr = self.calculator.get_correlation(Goal.ENERGY, Goal.AFFINITY)
        print(f"Energy-Affinity: {ea_corr}")
        self.assertAlmostEqual(ea_corr, self.expected_correlations["energy_affinity"], places=2)
        
        # Test Exploration-Affinity correlation
        ex_corr = self.calculator.get_correlation(Goal.EXPLORATION, Goal.AFFINITY)
        print(f"Exploration-Affinity: {ex_corr}")
        self.assertAlmostEqual(ex_corr, self.expected_correlations["exploration_affinity"], places=2)

    def test_symmetric_correlations(self):
        """
        Test that correlations are symmetric (corr(A,B) == corr(B,A)).
        
        Educational Note:
        Correlation should be symmetric - the correlation between Energy and
        Exploration should be the same regardless of which goal is listed first.
        This is a fundamental mathematical property we need to verify.
        """
        print("\n=== Symmetric Correlation Tests ===")
        
        # Test Energy-Exploration symmetry
        ee_1 = self.calculator.get_correlation(Goal.ENERGY, Goal.EXPLORATION)
        ee_2 = self.calculator.get_correlation(Goal.EXPLORATION, Goal.ENERGY)
        print(f"Energy-Exploration: {ee_1}, Exploration-Energy: {ee_2}")
        self.assertAlmostEqual(ee_1, ee_2, places=2)
        
        # Test Energy-Affinity symmetry
        ea_1 = self.calculator.get_correlation(Goal.ENERGY, Goal.AFFINITY)
        ea_2 = self.calculator.get_correlation(Goal.AFFINITY, Goal.ENERGY)
        print(f"Energy-Affinity: {ea_1}, Affinity-Energy: {ea_2}")
        self.assertAlmostEqual(ea_1, ea_2, places=2)
        
        # Test Exploration-Affinity symmetry
        ex_1 = self.calculator.get_correlation(Goal.EXPLORATION, Goal.AFFINITY)
        ex_2 = self.calculator.get_correlation(Goal.AFFINITY, Goal.EXPLORATION)
        print(f"Exploration-Affinity: {ex_1}, Affinity-Exploration: {ex_2}")
        self.assertAlmostEqual(ex_1, ex_2, places=2)

    def test_all_correlations_function(self):
        """
        Test the get_all_correlations function returns expected structure and values.
        
        Educational Note:
        This test validates that the bulk correlation retrieval function works
        correctly and returns data in the expected format for downstream processing.
        """
        print("\n=== All Correlations Function Test ===")
        
        all_correlations = self.calculator.get_all_correlations()
        
        # Verify we get exactly 3 correlations
        self.assertEqual(len(all_correlations), 3)
        
        # Verify structure: each item should be (goal1, goal2, correlation)
        for goal1, goal2, corr in all_correlations:
            self.assertIsInstance(goal1, Goal)
            self.assertIsInstance(goal2, Goal)
            self.assertIsInstance(corr, float)
            print(f"{goal1.value}-{goal2.value}: {corr}")
        
        # Extract correlation values and verify they match expected values
        correlation_values = [corr for _, _, corr in all_correlations]
        expected_values = [0.70, 0.50, 0.30]
        
        # Sort both lists to handle potential ordering differences
        correlation_values.sort(reverse=True)
        expected_values.sort(reverse=True)
        
        for actual, expected in zip(correlation_values, expected_values):
            self.assertAlmostEqual(actual, expected, places=2)

    def test_total_score_calculation(self):
        """
        Test total correlation score calculation.
        
        Educational Note:
        The total score is calculated as the simple average of all pairwise
        correlations. With target values of 0.7, 0.5, 0.3, we expect 0.5.
        """
        print("\n=== Total Score Test ===")
        
        total_score = self.calculator.calculate_total_score()
        print(f"Total Score: {total_score}")
        
        self.assertAlmostEqual(total_score, self.expected_total_score, places=2)
        
        # Manual verification calculation
        manual_total = (0.70 + 0.50 + 0.30) / 3
        print(f"Expected total (manual calculation): {manual_total}")
        self.assertAlmostEqual(total_score, manual_total, places=2)

    def test_data_availability_validation(self):
        """
        Test data availability validation function.
        
        Educational Note:
        Before performing any analysis, we need to ensure that we have sufficient
        data for each goal pair. This test validates the data availability checker.
        """
        print("\n=== Data Availability Validation Test ===")
        
        data_counts = self.calculator.validate_data_availability()
        
        # Verify all expected goal pairs are present
        expected_pairs = ["Energy-Exploration", "Energy-Affinity", "Exploration-Affinity"]
        for pair in expected_pairs:
            self.assertIn(pair, data_counts)
            count = data_counts[pair]
            self.assertGreater(count, 0, f"No data available for {pair}")
            print(f"{pair}: {count} data points")

    def test_discretization_function(self):
        """
        Test the discretization function with known values.
        
        Educational Note:
        The discretization function is critical for the MIC calculation.
        We test it with boundary values and representative values from each bin.
        """
        print("\n=== Discretization Function Test ===")
        
        # Test boundary values and representative values
        test_cases = [
            (0.0, 0),     # Lower bound of Low bin
            (0.33, 0),    # Upper bound of Low bin
            (0.34, 1),    # Lower bound of Mid bin  
            (0.5, 1),     # Middle of Mid bin
            (0.66, 1),    # Upper bound of Mid bin
            (0.67, 2),    # Lower bound of High bin
            (0.8, 2),     # Middle of High bin
            (1.0, 2)      # Upper bound of High bin
        ]
        
        for value, expected_bin in test_cases:
            actual_bin = self.calculator.discretize_value(value)
            print(f"Value {value} -> Bin {actual_bin} (expected {expected_bin})")
            self.assertEqual(actual_bin, expected_bin)

    def test_comprehensive_system(self):
        """
        Run the comprehensive test suite that mirrors the MeTTa run_correlation_tests function.
        
        Educational Note:
        This test replicates the full test suite from the MeTTa implementation,
        ensuring our Python version behaves identically to the original.
        """
        print("\n=== Comprehensive System Test ===")
        
        results = self.calculator.run_correlation_tests()
        
        # Validate the results structure
        self.assertIn("data_availability", results)
        self.assertIn("target_correlations", results)  
        self.assertIn("total_score", results)
        self.assertIn("all_correlations", results)
        
        # Validate target correlations
        target_corrs = results["target_correlations"]
        self.assertAlmostEqual(target_corrs["Energy-Exploration"], 0.70, places=2)
        self.assertAlmostEqual(target_corrs["Energy-Affinity"], 0.50, places=2)
        self.assertAlmostEqual(target_corrs["Exploration-Affinity"], 0.30, places=2)
        
        # Validate total score
        self.assertAlmostEqual(results["total_score"], 0.50, places=2)
        
        print("Comprehensive system test passed!")


def run_manual_tests():
    """
    Run manual tests that mirror the MeTTa test file structure.
    
    Educational Note:
    This function provides a more direct translation of the MeTTa test
    structure, showing how the Python implementation produces identical
    output to the original MeTTa version.
    """
    print("=" * 60)
    print("MAGUS Correlation System - Manual Test Suite")
    print("=" * 60)
    
    calculator = CorrelationCalculator()
    
    # Mirror the MeTTa test structure
    print("\n=== Individual Correlation Tests ===")
    print(f"Energy-Exploration: {calculator.get_correlation(Goal.ENERGY, Goal.EXPLORATION)}")
    print(f"Energy-Affinity: {calculator.get_correlation(Goal.ENERGY, Goal.AFFINITY)}")
    print(f"Exploration-Affinity: {calculator.get_correlation(Goal.EXPLORATION, Goal.AFFINITY)}")
    
    print("\n=== All Correlations Test ===")
    all_corrs = calculator.get_all_correlations()
    for goal1, goal2, corr in all_corrs:
        print(f"{goal1.value}-{goal2.value}: {corr}")
    
    print("\n=== Total Score Test ===")
    total_score = calculator.calculate_total_score()
    print(f"Total Score: {total_score}")
    
    print("\n=== Manual Verification ===")
    expected_total = (0.7 + 0.5 + 0.3) / 3
    print(f"Expected total: {expected_total}")
    
    print(f"\nValidation: Total score matches expected: {abs(total_score - expected_total) < 0.01}")


if __name__ == "__main__":
    # Run manual tests first (mirroring MeTTa output)
    run_manual_tests()
    
    # Then run the formal unit tests
    print("\n" + "=" * 60)
    print("Running Unit Tests...")
    print("=" * 60)
    unittest.main(verbosity=2)