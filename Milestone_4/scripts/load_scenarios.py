#!/usr/bin/env python3
"""
MAGUS Milestone 4 - YAML Scenario Loader
Loads ethical scenarios from YAML and registers them in MeTTa space
Implements ES2: Parse YAML and bind scenarios into dedicated spaces
"""

import yaml
from pathlib import Path
from hyperon import MeTTa, E, S, ValueAtom
from typing import Dict, List, Any, Optional
import sys

class ScenarioLoader:
    """Loads YAML scenarios and registers them in MeTTa"""

    def __init__(self, metta: MeTTa):
        self.metta = metta

    def load_scenario_config(self, yaml_path: Path) -> Dict[str, Any]:
        """Load scenario configuration from YAML file"""
        with open(yaml_path, 'r') as f:
            config = yaml.safe_load(f)
        return config

    def yaml_to_metta_context(self, context_data: Dict[str, Any]) -> str:
        """Convert YAML context to MeTTa context expression"""
        location = context_data.get('location', 'unknown')
        agent_state = context_data.get('agent-state', 'normal')
        danger = context_data.get('environment-danger', 'neutral')

        # Build properties list from remaining keys
        properties = []
        for key, value in context_data.items():
            if key not in ['location', 'agent-state', 'environment-danger']:
                # Convert complex values to nested structures
                if isinstance(value, dict):
                    prop_value = self._dict_to_metta(value)
                elif isinstance(value, list):
                    prop_value = self._list_to_metta(value)
                else:
                    prop_value = str(value)
                properties.append(f"(Tuple {key} {prop_value})")

        props_list = f"(list {' '.join(properties)})" if properties else "Nil"

        return f"(context {location} {agent_state} {danger} {props_list})"

    def _dict_to_metta(self, d: Dict) -> str:
        """Convert Python dict to MeTTa list of tuples"""
        items = [f"(Tuple {k} {v})" for k, v in d.items()]
        return f"(list {' '.join(items)})"

    def _list_to_metta(self, lst: List) -> str:
        """Convert Python list to MeTTa list"""
        if not lst:
            return "Nil"
        if isinstance(lst[0], dict):
            items = [self._dict_to_metta(item) for item in lst]
        else:
            items = [str(item) for item in lst]
        return f"(list {' '.join(items)})"

    def yaml_to_metta_goal(self, goal_data: Dict[str, Any]) -> str:
        """Convert YAML goal to MeTTa Goal expression"""
        name = goal_data.get('name', 'unknown')
        priority = goal_data.get('priority', 0.5)
        weight = goal_data.get('weight', 1.0)
        description = goal_data.get('description', '')

        return f'(goal {name} {priority} {weight})'

    def yaml_to_metta_antigoal(self, ag_data: Dict[str, Any], is_hard: bool) -> str:
        """Convert YAML anti-goal to MeTTa AntiGoal expression"""
        name = ag_data.get('name', 'unknown')
        threshold = ag_data.get('threshold', 0.0)

        if is_hard:
            return f'(hard-antigoal {name} {threshold})'
        else:
            penalty_weight = ag_data.get('penalty-weight', 0.5)
            return f'(soft-antigoal {name} {threshold} {penalty_weight})'

    def yaml_to_metta_metric(self, metric_name: str, metric_value: Any) -> str:
        """Convert YAML success metric to MeTTa SuccessMetric"""
        # Parse metric patterns
        if isinstance(metric_value, bool):
            return f'(metric-boolean {metric_name} {str(metric_value)})'
        elif isinstance(metric_value, str):
            # Parse comparison operators
            if '>=' in metric_value:
                threshold = metric_value.split('>=')[1].strip()
                return f'(metric-comparison {metric_name} >= {threshold})'
            elif '>' in metric_value:
                threshold = metric_value.split('>')[1].strip()
                return f'(metric-comparison {metric_name} > {threshold})'
            elif '<=' in metric_value:
                threshold = metric_value.split('<=')[1].strip()
                return f'(metric-comparison {metric_name} <= {threshold})'
            elif '<' in metric_value:
                threshold = metric_value.split('<')[1].strip()
                return f'(metric-comparison {metric_name} < {threshold})'
            elif '==' in metric_value:
                expected = metric_value.split('==')[1].strip()
                return f'(metric-comparison {metric_name} == {expected})'

        # Default to boolean True
        return f'(metric-boolean {metric_name} True)'

    def yaml_to_metta_action(self, action_data: Dict[str, Any]) -> str:
        """Convert YAML expected action to MeTTa ExpectedAction"""
        action_name = action_data.get('action', 'unknown')
        params = action_data.get('parameters', [])
        rationale = action_data.get('rationale', '').replace('"', '\\"')

        params_list = f"(list {' '.join(str(p) for p in params)})" if params else "Nil"

        return f'(expected-action {action_name} {params_list} "{rationale}")'

    def register_scenario(self, scenario_data: Dict[str, Any]) -> bool:
        """Register a single scenario in MeTTa"""
        try:
            scenario_id = scenario_data['id']
            description = scenario_data.get('description', '').replace('"', '\\"')
            tags = scenario_data.get('tags', [])
            risk_level = scenario_data.get('risk-level', 'medium')

            # Convert context
            context_expr = self.yaml_to_metta_context(scenario_data['context'])

            # Convert goals
            goals = [self.yaml_to_metta_goal(g) for g in scenario_data['goals']]
            goals_list = f"(list {' '.join(goals)})"

            # Convert anti-goals
            antigoals = []
            ag_data = scenario_data.get('anti-goals', {})
            if 'hard' in ag_data:
                antigoals.extend([
                    self.yaml_to_metta_antigoal(ag, True)
                    for ag in ag_data['hard']
                ])
            if 'soft' in ag_data:
                antigoals.extend([
                    self.yaml_to_metta_antigoal(ag, False)
                    for ag in ag_data['soft']
                ])
            antigoals_list = f"(list {' '.join(antigoals)})" if antigoals else "Nil"

            # Convert success metrics
            metrics = []
            for metric_item in scenario_data.get('success-metrics', []):
                if isinstance(metric_item, str):
                    # Simple boolean metric
                    metrics.append(f'(metric-boolean {metric_item} True)')
                elif isinstance(metric_item, dict):
                    # Complex metric with value
                    for key, value in metric_item.items():
                        metrics.append(self.yaml_to_metta_metric(key, value))
            metrics_list = f"(list {' '.join(metrics)})"

            # Convert expected plan
            plan = [self.yaml_to_metta_action(a) for a in scenario_data.get('expected-plan', [])]
            plan_list = f"(list {' '.join(plan)})" if plan else "Nil"

            # Get remediation hint
            remediation = scenario_data.get('remediation-hint', '').replace('"', '\\"')

            # Build tags list
            tags_list = f"(list {' '.join(tags)})" if tags else "Nil"

            # Construct full scenario expression
            scenario_expr = f'''(register-scenario
  (scenario
    {scenario_id}
    "{description}"
    {tags_list}
    {risk_level}
    {context_expr}
    {goals_list}
    {antigoals_list}
    {metrics_list}
    {plan_list}
    "{remediation}"))'''

            # Execute registration
            result = self.metta.run(f'!{scenario_expr}')

            print(f"✅ Registered scenario: {scenario_id}")
            return True

        except Exception as e:
            print(f"❌ Failed to register scenario {scenario_data.get('id', 'unknown')}: {e}")
            import traceback
            traceback.print_exc()
            return False

    def load_all_scenarios(self, yaml_path: Path) -> int:
        """Load all scenarios from YAML file"""
        config = self.load_scenario_config(yaml_path)
        scenarios = config.get('scenarios', [])

        success_count = 0
        for scenario in scenarios:
            if self.register_scenario(scenario):
                success_count += 1

        return success_count


def main():
    """Main entry point for scenario loading"""
    print("="*70)
    print("  MAGUS M4 - Ethical Scenario Loader")
    print("="*70)

    # Initialize MeTTa
    metta = MeTTa()

    # Load required modules
    base_dir = Path(__file__).parent.parent

    print("\nLoading MeTTa modules...")
    modules = [
        base_dir / 'types.metta',
        base_dir / 'Milestone_4' / 'ethical' / 'scenarios.metta',
    ]

    for module_path in modules:
        if module_path.exists():
            print(f"  Loading {module_path.name}...")
            with open(module_path, 'r') as f:
                metta.run(f.read())
        else:
            print(f"  ⚠️  Module not found: {module_path}")

    # Load scenarios from YAML
    yaml_path = base_dir / 'Milestone_4' / 'ethical' / 'scenario-config.yaml'

    if not yaml_path.exists():
        print(f"\n❌ Scenario config not found: {yaml_path}")
        return 1

    print(f"\nLoading scenarios from {yaml_path.name}...")
    loader = ScenarioLoader(metta)

    success_count = loader.load_all_scenarios(yaml_path)

    # Report statistics
    print("\n" + "="*70)
    print("  SCENARIO LOADING COMPLETE")
    print("="*70)
    print(f"\n✅ Successfully loaded: {success_count} scenarios")

    # Query scenario statistics
    result = metta.run('!(total-scenarios)')
    print(f"Total scenarios in space: {result}")

    result = metta.run('!(scenario-coverage)')
    print(f"Coverage by category: {result}")

    return 0 if success_count > 0 else 1


if __name__ == '__main__':
    sys.exit(main())
