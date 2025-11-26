#!/usr/bin/env python3
"""
MAGUS Action Evaluation Prototype v1 - Python Implementation
===========================================================
Python mirror of magus-action-evaluation-prototype-v1.metta
- Uses geometric mean for considerations (higher = better for goal)
- Uses product for discouragements (lower = more blocking)
- Goal score = weight * geometric_mean(considerations) * product(discouragements)
- Total action score = sum of all goal scores
"""

import math

# Goal weights from the MeTTa goal weighting system
GOAL_WEIGHTS = {
    'exploration': 0.3,  # importance=0.6, satisfaction=0.5 -> weight=0.6*(1-0.5)=0.3
    'affinity': 0.35,    # importance=0.7, satisfaction=0.5 -> weight=0.7*(1-0.5)=0.35
    'energy': 0.63       # importance=0.9, satisfaction=0.3 -> weight=0.9*(1-0.3)=0.63
}

def geometric_mean(values):
    """Calculate geometric mean of a list of values"""
    if not values: return 0.0
    if len(values) == 1: return values[0]
    product = 1.0
    for v in values: product *= v
    return product ** (1.0 / len(values))

def product_discouragements(values):
    """Calculate product of discouragements (empty list = 1.0, no blocking)"""
    if not values: return 1.0
    result = 1.0
    for v in values: result *= v
    return result

def evaluate_action(action_data):
    """Evaluate one action across all goals, return total score"""
    total_score = 0.0
    print(f"\n{action_data['name'].upper()} Action:")
    
    for goal_name, weight in GOAL_WEIGHTS.items():
        considerations = action_data['goals'][goal_name]['considerations']
        discouragements = action_data['goals'][goal_name]['discouragements']
        
        cons_score = geometric_mean(considerations)
        disc_score = product_discouragements(discouragements)
        goal_score = weight * cons_score * disc_score
        total_score += goal_score
        
        print(f"  {goal_name}: {weight:.2f} * {cons_score:.3f} * {disc_score:.3f} = {goal_score:.3f}")
    
    print(f"  TOTAL: {total_score:.3f}")
    return total_score

# Test data matching the MeTTa implementation exactly
actions = {
    'rest': {
        'name': 'rest',
        'goals': {
            'exploration': {'considerations': [0.2, 0.3], 'discouragements': [0.8, 0.9]},
            'affinity': {'considerations': [0.4, 0.6, 0.5], 'discouragements': [0.9]},
            'energy': {'considerations': [0.9], 'discouragements': [0.7, 0.8]}
        }
    },
    'explore': {
        'name': 'explore', 
        'goals': {
            'exploration': {'considerations': [0.8, 0.9, 0.7], 'discouragements': [0.6]},
            'affinity': {'considerations': [0.1], 'discouragements': [0.9, 0.8]},
            'energy': {'considerations': [0.2, 0.1], 'discouragements': [0.4, 0.3, 0.5]}
        }
    }
}

if __name__ == "__main__":
    print("=== MAGUS Action Evaluation Test ===")
    
    rest_score = evaluate_action(actions['rest'])
    explore_score = evaluate_action(actions['explore'])
    
    print(f"\nRESULT:")
    if rest_score > explore_score:
        print(f"Winner: REST ({rest_score:.3f} > {explore_score:.3f})")
    else:
        print(f"Winner: EXPLORE ({explore_score:.3f} > {rest_score:.3f})")