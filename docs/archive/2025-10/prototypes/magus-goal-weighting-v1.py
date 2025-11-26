"""
MAGUS Goal Weighting System v1 - Python Version
Simple goal weight calculation: weight = importance * urgency
Where urgency = 1.0 - current_satisfaction
"""

class GoalWeightingV1:
    def __init__(self):
        # Goals: (importance, current_satisfaction)
        self.goals = {
            'exploration': (0.6, 0.5),
            'affinity': (0.7, 0.5), 
            'energy': (0.9, 0.3)
        }
    
    def calculate_urgency(self, satisfaction):
        """Urgency = 1.0 - satisfaction (less satisfied = more urgent)"""
        return 1.0 - satisfaction
    
    def calculate_goal_weight(self, importance, urgency):
        """Weight = importance * urgency"""
        return importance * urgency
    
    def get_goal_weight(self, goal_name):
        """Get weight for specific goal"""
        importance, satisfaction = self.goals[goal_name]
        urgency = self.calculate_urgency(satisfaction)
        return self.calculate_goal_weight(importance, urgency)
    
    def get_all_weights(self):
        """Get all goal weights"""
        return {goal: self.get_goal_weight(goal) for goal in self.goals}

# Test - should match MeTTa output
if __name__ == "__main__":
    gw = GoalWeightingV1()
    print("Goal Weights:")
    for goal, weight in gw.get_all_weights().items():
        print(f"{goal}: {weight}")
    
    # Expected: exploration=0.3, affinity=0.35, energy=0.63