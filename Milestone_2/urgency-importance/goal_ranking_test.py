"""
Goal Ranking System - Python Implementation
Implements dynamic goal prioritization based on urgency and importance
Matches the working MeTTa implementation functionality
"""

class Goal:
    """Represents a goal with its importance value"""
    def __init__(self, name, importance):
        self.name = name
        self.importance = importance
    
    def calculate_priority(self, satisfaction):
        """Calculate goal priority: Priority = Urgency × Importance"""
        urgency = 1.0 - satisfaction
        return urgency * self.importance

class GoalRankingSystem:
    """Main system for ranking goals based on satisfaction levels"""
    
    def __init__(self):
        # Initialize the three main goals with fixed importance values
        self.goals = {
            'Energy': Goal('Energy', 0.8),
            'Cognitive': Goal('Cognitive', 0.6), 
            'Social': Goal('Social', 0.7)
        }
    
    def calculate_priorities(self, satisfaction_levels):
        """Calculate priorities for all goals given satisfaction levels"""
        priorities = {}
        for goal_name, satisfaction in satisfaction_levels.items():
            if goal_name in self.goals:
                priority = self.goals[goal_name].calculate_priority(satisfaction)
                priorities[goal_name] = priority
        return priorities
    
    def get_primary_goal(self, satisfaction_levels):
        """Determine which goal has the highest priority"""
        priorities = self.calculate_priorities(satisfaction_levels)
        if not priorities:
            return None, {}
        
        primary_goal = max(priorities, key=priorities.get)
        return primary_goal, priorities
    
    def rank_goals(self, satisfaction_levels):
        """Return goals ranked by priority (highest first)"""
        priorities = self.calculate_priorities(satisfaction_levels)
        return sorted(priorities.items(), key=lambda x: x[1], reverse=True)

class TestScenario:
    """Represents a test scenario with expected results"""
    
    def __init__(self, name, satisfaction_levels, expected_primary):
        self.name = name
        self.satisfaction_levels = satisfaction_levels
        self.expected_primary = expected_primary
    
    def run_test(self, ranking_system):
        """Run the test scenario and validate results"""
        primary_goal, priorities = ranking_system.get_primary_goal(self.satisfaction_levels)
        passed = primary_goal == self.expected_primary
        
        return {
            'name': self.name,
            'satisfaction_levels': self.satisfaction_levels,
            'priorities': priorities,
            'primary_goal': primary_goal,
            'expected_primary': self.expected_primary,
            'passed': passed
        }

def run_all_tests():
    """Run all test scenarios and display results"""
    
    # Initialize the ranking system
    ranking_system = GoalRankingSystem()
    
    # Define test scenarios (matching MeTTa implementation)
    scenarios = [
        TestScenario(
            "Energy Crisis",
            {'Energy': 0.1, 'Cognitive': 0.7, 'Social': 0.6},
            'Energy'
        ),
        TestScenario(
            "Social Isolation", 
            {'Energy': 0.8, 'Cognitive': 0.7, 'Social': 0.2},
            'Social'
        ),
        TestScenario(
            "Knowledge Gap",
            {'Energy': 0.7, 'Cognitive': 0.1, 'Social': 0.7},
            'Cognitive' 
        ),
        TestScenario(
            "Balanced State",
            {'Energy': 0.5, 'Cognitive': 0.5, 'Social': 0.5},
            'Energy'
        )
    ]
    
    # Display system information
    print("=== GOAL RANKING SYSTEM TEST RESULTS ===")
    print("")
    print("Formula: Priority = (1.0 - satisfaction) × importance")
    print("Importance: Energy=0.8, Cognitive=0.6, Social=0.7")
    print("")
    
    # Run all tests
    test_results = []
    for i, scenario in enumerate(scenarios, 1):
        result = scenario.run_test(ranking_system)
        test_results.append(result)
        
        # Display test result
        status = "✓ PASSED" if result['passed'] else "✗ FAILED"
        print(f"TEST {i} - {result['name']}")
        print(f"{status}")
        
        # Show priorities for each goal
        for goal_name in ['Energy', 'Cognitive', 'Social']:
            priority = result['priorities'].get(goal_name, 0.0)
            print(f"{goal_name}: {priority:.2f}")
        
        print(f"Primary: {result['primary_goal']} (Expected: {result['expected_primary']})")
        print("")
    
    # Summary
    print("=== ALL TESTS COMPLETE ===")
    passed_count = sum(1 for result in test_results if result['passed'])
    print(f"Summary: {passed_count}/{len(test_results)} tests passed")
    
    for i, result in enumerate(test_results, 1):
        status = "PASSED" if result['passed'] else "FAILED"
        print(f"Test {i}: {status}")
    
    return test_results

def demonstrate_custom_calculation():
    """Demonstrate custom goal ranking calculation"""
    ranking_system = GoalRankingSystem()
    
    print("\n=== CUSTOM CALCULATION EXAMPLE ===")
    
    # Custom satisfaction levels
    custom_satisfaction = {'Energy': 0.3, 'Cognitive': 0.8, 'Social': 0.5}
    
    primary_goal, priorities = ranking_system.get_primary_goal(custom_satisfaction)
    ranked_goals = ranking_system.rank_goals(custom_satisfaction)
    
    print("Custom satisfaction levels:")
    for goal, satisfaction in custom_satisfaction.items():
        print(f"{goal}: {satisfaction}")
    
    print("\nCalculated priorities:")
    for goal, priority in priorities.items():
        print(f"{goal}: {priority:.2f}")
    
    print(f"\nRanked goals: {[goal for goal, _ in ranked_goals]}")
    print(f"Primary goal: {primary_goal}")

if __name__ == "__main__":
    # Run the main test suite
    test_results = run_all_tests()
    
    # Demonstrate custom calculation
    demonstrate_custom_calculation()
    
    # Check if all tests passed
    all_passed = all(result['passed'] for result in test_results)
    if all_passed:
        print(f"\n🎉 All tests passed! Goal ranking system working correctly.")
    else:
        print(f"\n❌ Some tests failed. Check implementation.")