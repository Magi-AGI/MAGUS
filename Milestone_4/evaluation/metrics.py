#!/usr/bin/env python3
"""
MAGUS Milestone 4 - Metrics Aggregation and Reporting
Implements EV4: Ingest logs, produce CSV tables and plots
"""

import json
import csv
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from collections import defaultdict
import sys

# Optional dependencies for plotting
try:
    import matplotlib.pyplot as plt
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("WARNING: matplotlib not available - plots will be skipped")

try:
    import pandas as pd
    HAS_PANDAS = True
except ImportError:
    HAS_PANDAS = False
    print("WARNING: pandas not available - using csv module")


@dataclass
class MetricRecord:
    """Single metric measurement"""
    scenario_id: str
    configuration: str
    metric_name: str
    value: float
    timestamp: Optional[str] = None


@dataclass
class AggregatedMetrics:
    """Aggregated metrics for a configuration"""
    configuration: str
    total_scenarios: int
    goal_satisfaction_mean: float
    hard_violations_total: int
    soft_violations_total: int
    decision_latency_mean: float
    metagoal_contribution_mean: float
    antigoal_penalty_mean: float
    plan_length_mean: float


@dataclass
class AblationComparison:
    """Comparison between baseline and ablated configuration"""
    configuration: str
    metric_name: str
    baseline_value: float
    ablated_value: float
    delta: float
    percent_change: float


def setup_console_encoding():
    """Setup UTF-8 encoding for Windows console"""
    import sys
    if sys.platform == 'win32':
        try:
            if hasattr(sys.stdout, 'reconfigure'):
                sys.stdout.reconfigure(encoding='utf-8')
            if hasattr(sys.stderr, 'reconfigure'):
                sys.stderr.reconfigure(encoding='utf-8')
        except Exception:
            pass  # Silently fail if reconfigure not available


class MetricsAggregator:
    """Aggregates and analyzes metrics from ethical scenario runs"""

    def __init__(self, results_dir: Path, figures_dir: Path):
        self.results_dir = results_dir
        self.figures_dir = figures_dir
        self.results_dir.mkdir(parents=True, exist_ok=True)
        self.figures_dir.mkdir(parents=True, exist_ok=True)

        self.metrics: List[MetricRecord] = []

    def load_json_logs(self, log_path: Path) -> List[Dict[str, Any]]:
        """Load JSON lines log file"""
        logs = []
        with open(log_path, 'r') as f:
            for line in f:
                if line.strip():
                    try:
                        logs.append(json.loads(line))
                    except json.JSONDecodeError as e:
                        print(f"WARNING: Failed to parse JSON line: {e}")
        return logs

    def extract_metrics_from_log(self, log_entry: Dict[str, Any]) -> List[MetricRecord]:
        """Extract metrics from a single log entry"""
        metrics = []
        scenario_id = log_entry.get('scenarioId', 'unknown')
        config = log_entry.get('configuration', 'default')

        # Extract standard metrics
        metric_mappings = {
            'decisionScore': 'goal-satisfaction-after',
            'latencyMs': 'decision-latency-ms',
            'hardViolations': 'hard-violation-count',
            'softViolations': 'soft-violation-count',
        }

        for json_key, metric_name in metric_mappings.items():
            if json_key in log_entry:
                metrics.append(MetricRecord(
                    scenario_id=scenario_id,
                    configuration=config,
                    metric_name=metric_name,
                    value=float(log_entry[json_key]),
                    timestamp=log_entry.get('timestamp')
                ))

        # Extract metagoal contributions
        if 'metagoal' in log_entry and isinstance(log_entry['metagoal'], dict):
            total_contribution = sum(abs(v) for v in log_entry['metagoal'].values())
            metrics.append(MetricRecord(
                scenario_id=scenario_id,
                configuration=config,
                metric_name='metagoal-contribution-total',
                value=total_contribution,
                timestamp=log_entry.get('timestamp')
            ))

        # Extract anti-goal penalties
        if 'antigoal' in log_entry and isinstance(log_entry['antigoal'], dict):
            total_penalty = sum(v for v in log_entry['antigoal'].values() if v > 0)
            metrics.append(MetricRecord(
                scenario_id=scenario_id,
                configuration=config,
                metric_name='antigoal-penalty-total',
                value=total_penalty,
                timestamp=log_entry.get('timestamp')
            ))

        # Extract plan length
        if 'plan' in log_entry:
            if isinstance(log_entry['plan'], list):
                plan_length = len(log_entry['plan'])
            else:
                plan_length = 1
            metrics.append(MetricRecord(
                scenario_id=scenario_id,
                configuration=config,
                metric_name='plan-length',
                value=float(plan_length),
                timestamp=log_entry.get('timestamp')
            ))

        return metrics

    def load_all_logs(self, log_dir: Path) -> None:
        """Load all JSON log files from directory"""
        for log_file in log_dir.glob('*.jsonl'):
            print(f"Loading {log_file.name}...")
            logs = self.load_json_logs(log_file)
            for log_entry in logs:
                self.metrics.extend(self.extract_metrics_from_log(log_entry))

        print(f"SUCCESS: Loaded {len(self.metrics)} metric records")

    def aggregate_by_configuration(self) -> Dict[str, AggregatedMetrics]:
        """Aggregate metrics by configuration"""
        configs = defaultdict(lambda: {
            'scenarios': set(),
            'goal-satisfaction-after': [],
            'hard-violation-count': [],
            'soft-violation-count': [],
            'decision-latency-ms': [],
            'metagoal-contribution-total': [],
            'antigoal-penalty-total': [],
            'plan-length': []
        })

        # Group metrics by configuration
        for metric in self.metrics:
            config_data = configs[metric.configuration]
            config_data['scenarios'].add(metric.scenario_id)
            if metric.metric_name in config_data:
                config_data[metric.metric_name].append(metric.value)

        # Calculate aggregates
        aggregated = {}
        for config, data in configs.items():
            aggregated[config] = AggregatedMetrics(
                configuration=config,
                total_scenarios=len(data['scenarios']),
                goal_satisfaction_mean=self._safe_mean(data['goal-satisfaction-after']),
                hard_violations_total=int(sum(data['hard-violation-count'])),
                soft_violations_total=int(sum(data['soft-violation-count'])),
                decision_latency_mean=self._safe_mean(data['decision-latency-ms']),
                metagoal_contribution_mean=self._safe_mean(data['metagoal-contribution-total']),
                antigoal_penalty_mean=self._safe_mean(data['antigoal-penalty-total']),
                plan_length_mean=self._safe_mean(data['plan-length'])
            )

        return aggregated

    def _safe_mean(self, values: List[float]) -> float:
        """Calculate mean with safety for empty lists"""
        return sum(values) / len(values) if values else 0.0

    def write_summary_csv(self, aggregated: Dict[str, AggregatedMetrics]) -> Path:
        """Write summary CSV table"""
        output_path = self.results_dir / 'summary.csv'

        with open(output_path, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=[
                'configuration',
                'total_scenarios',
                'goal_satisfaction_mean',
                'hard_violations_total',
                'soft_violations_total',
                'decision_latency_mean',
                'metagoal_contribution_mean',
                'antigoal_penalty_mean',
                'plan_length_mean'
            ])
            writer.writeheader()

            for metrics in aggregated.values():
                writer.writerow(asdict(metrics))

        print(f"SUCCESS: Summary CSV written to {output_path}")
        return output_path

    def calculate_ablation_deltas(
        self,
        aggregated: Dict[str, AggregatedMetrics],
        baseline: str = 'full-system'
    ) -> List[AblationComparison]:
        """Calculate deltas between baseline and ablated configurations"""
        if baseline not in aggregated:
            print(f"WARNING: Baseline configuration '{baseline}' not found")
            return []

        baseline_metrics = aggregated[baseline]
        comparisons = []

        metric_fields = [
            'goal_satisfaction_mean',
            'hard_violations_total',
            'soft_violations_total',
            'decision_latency_mean',
            'metagoal_contribution_mean',
            'antigoal_penalty_mean',
            'plan_length_mean'
        ]

        for config, metrics in aggregated.items():
            if config == baseline:
                continue

            for field in metric_fields:
                baseline_value = getattr(baseline_metrics, field)
                ablated_value = getattr(metrics, field)
                delta = ablated_value - baseline_value

                percent_change = 0.0
                if baseline_value != 0:
                    percent_change = (delta / baseline_value) * 100

                comparisons.append(AblationComparison(
                    configuration=config,
                    metric_name=field,
                    baseline_value=baseline_value,
                    ablated_value=ablated_value,
                    delta=delta,
                    percent_change=percent_change
                ))

        return comparisons

    def write_ablations_csv(self, comparisons: List[AblationComparison]) -> Path:
        """Write ablation comparison CSV"""
        output_path = self.results_dir / 'ablations.csv'

        with open(output_path, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=[
                'configuration',
                'metric_name',
                'baseline_value',
                'ablated_value',
                'delta',
                'percent_change'
            ])
            writer.writeheader()

            for comp in comparisons:
                writer.writerow(asdict(comp))

        print(f"SUCCESS: Ablations CSV written to {output_path}")
        return output_path

    def plot_configuration_comparison(
        self,
        aggregated: Dict[str, AggregatedMetrics]
    ) -> Optional[Path]:
        """Create bar plot comparing configurations"""
        if not HAS_MATPLOTLIB:
            print("WARNING: Skipping plots (matplotlib not available)")
            return None

        # Prepare data
        configs = list(aggregated.keys())
        goal_sat = [aggregated[c].goal_satisfaction_mean for c in configs]
        hard_viols = [aggregated[c].hard_violations_total for c in configs]
        soft_viols = [aggregated[c].soft_violations_total for c in configs]

        # Create figure with subplots
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        # Goal satisfaction
        axes[0].bar(configs, goal_sat, color='steelblue')
        axes[0].set_title('Goal Satisfaction (Mean)')
        axes[0].set_ylabel('Score')
        axes[0].tick_params(axis='x', rotation=45)

        # Hard violations
        axes[1].bar(configs, hard_viols, color='crimson')
        axes[1].set_title('Hard Violations (Total)')
        axes[1].set_ylabel('Count')
        axes[1].tick_params(axis='x', rotation=45)

        # Soft violations
        axes[2].bar(configs, soft_viols, color='orange')
        axes[2].set_title('Soft Violations (Total)')
        axes[2].set_ylabel('Count')
        axes[2].tick_params(axis='x', rotation=45)

        plt.tight_layout()

        output_path = self.figures_dir / 'configuration_comparison.png'
        plt.savefig(output_path, dpi=150, bbox_inches='tight')
        plt.close()

        print(f"SUCCESS: Configuration comparison plot saved to {output_path}")
        return output_path

    def plot_ablation_deltas(
        self,
        comparisons: List[AblationComparison]
    ) -> Optional[Path]:
        """Create plot showing ablation deltas"""
        if not HAS_MATPLOTLIB:
            return None

        # Group by configuration
        config_deltas = defaultdict(lambda: {'metrics': [], 'deltas': []})

        for comp in comparisons:
            if 'violation' in comp.metric_name:  # Focus on key metrics
                config_deltas[comp.configuration]['metrics'].append(
                    comp.metric_name.replace('_', ' ').title()
                )
                config_deltas[comp.configuration]['deltas'].append(comp.delta)

        # Create grouped bar chart
        fig, ax = plt.subplots(figsize=(12, 6))

        configs = list(config_deltas.keys())
        x = range(len(config_deltas[configs[0]]['metrics']))
        width = 0.2

        for i, config in enumerate(configs):
            offset = (i - len(configs)/2) * width
            ax.bar(
                [xi + offset for xi in x],
                config_deltas[config]['deltas'],
                width,
                label=config
            )

        ax.set_xlabel('Metric')
        ax.set_ylabel('Delta from Baseline')
        ax.set_title('Ablation Study: Change in Violations')
        ax.set_xticks(x)
        ax.set_xticklabels(config_deltas[configs[0]]['metrics'], rotation=45, ha='right')
        ax.legend()
        ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
        ax.grid(axis='y', alpha=0.3)

        plt.tight_layout()

        output_path = self.figures_dir / 'ablation_deltas.png'
        plt.savefig(output_path, dpi=150, bbox_inches='tight')
        plt.close()

        print(f"SUCCESS: Ablation deltas plot saved to {output_path}")
        return output_path

    def generate_evaluation_report(
        self,
        aggregated: Dict[str, AggregatedMetrics],
        comparisons: List[AblationComparison],
        template_path: Optional[Path] = None
    ) -> Path:
        """Generate evaluation report markdown"""
        output_path = self.results_dir.parent / 'docs' / 'evaluation-report.md'
        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, 'w') as f:
            f.write("# MAGUS M4 - Ethical Evaluation Report\n\n")
            f.write("**Generated:** Automatically from metrics aggregation\n\n")

            # Summary statistics
            f.write("## Summary Statistics\n\n")
            f.write("| Configuration | Scenarios | Goal Sat. | Hard Viol. | Soft Viol. | Latency (ms) |\n")
            f.write("|--------------|-----------|-----------|-----------|------------|-------------|\n")

            for config, metrics in aggregated.items():
                f.write(f"| {config} | {metrics.total_scenarios} | "
                       f"{metrics.goal_satisfaction_mean:.3f} | "
                       f"{metrics.hard_violations_total} | "
                       f"{metrics.soft_violations_total} | "
                       f"{metrics.decision_latency_mean:.2f} |\n")

            # Ablation analysis
            f.write("\n## Ablation Analysis\n\n")
            f.write("Changes relative to full-system baseline:\n\n")
            f.write("| Configuration | Metric | Baseline | Ablated | Delta | % Change |\n")
            f.write("|--------------|--------|----------|---------|-------|----------|\n")

            for comp in comparisons:
                if abs(comp.delta) > 0.01:  # Only show meaningful changes
                    f.write(f"| {comp.configuration} | {comp.metric_name} | "
                           f"{comp.baseline_value:.3f} | {comp.ablated_value:.3f} | "
                           f"{comp.delta:+.3f} | {comp.percent_change:+.1f}% |\n")

            # Key findings
            f.write("\n## Key Findings\n\n")
            f.write("### Hard Violations\n")
            for config, metrics in aggregated.items():
                if metrics.hard_violations_total > 0:
                    f.write(f"- **{config}**: {metrics.hard_violations_total} hard violations detected\n")

            f.write("\n### Metagoal Impact\n")
            no_mg = aggregated.get('no-metagoals')
            full = aggregated.get('full-system')
            if no_mg and full:
                delta = full.goal_satisfaction_mean - no_mg.goal_satisfaction_mean
                f.write(f"- Metagoals improve goal satisfaction by {delta:+.3f}\n")

            f.write("\n### Anti-goal Impact\n")
            no_ag = aggregated.get('no-antigoals')
            if no_ag and full:
                viol_increase = no_ag.hard_violations_total - full.hard_violations_total
                f.write(f"- Disabling anti-goals increases hard violations by {viol_increase:+d}\n")

        print(f"SUCCESS: Evaluation report written to {output_path}")
        return output_path


def main():
    """Main entry point"""
    setup_console_encoding()

    print("="*70)
    print("  MAGUS M4 - Metrics Aggregation")
    print("="*70)

    base_dir = Path(__file__).parent.parent
    results_dir = base_dir / 'evaluation' / 'results'
    figures_dir = base_dir / 'evaluation' / 'figures'
    logs_dir = base_dir / 'evaluation' / 'logs'

    # Create aggregator
    aggregator = MetricsAggregator(results_dir, figures_dir)

    # Load logs
    if logs_dir.exists():
        print(f"\nLoading logs from {logs_dir}...")
        aggregator.load_all_logs(logs_dir)
    else:
        print(f"\nWARNING: No logs directory found at {logs_dir}")
        print("Creating sample metrics for demonstration...")
        # Create sample data for testing
        aggregator.metrics = _create_sample_metrics()

    # Aggregate by configuration
    print("\nAggregating metrics by configuration...")
    aggregated = aggregator.aggregate_by_configuration()

    # Write summary CSV
    aggregator.write_summary_csv(aggregated)

    # Calculate ablation deltas
    print("\nCalculating ablation deltas...")
    comparisons = aggregator.calculate_ablation_deltas(aggregated)

    if comparisons:
        aggregator.write_ablations_csv(comparisons)

    # Generate plots
    if HAS_MATPLOTLIB:
        print("\nGenerating plots...")
        aggregator.plot_configuration_comparison(aggregated)
        if comparisons:
            aggregator.plot_ablation_deltas(comparisons)

    # Generate report
    print("\nGenerating evaluation report...")
    aggregator.generate_evaluation_report(aggregated, comparisons)

    print("\n" + "="*70)
    print("  METRICS AGGREGATION COMPLETE")
    print("="*70)

    return 0


def _create_sample_metrics() -> List[MetricRecord]:
    """Create sample metrics for testing"""
    scenarios = ['safety-override', 'resource-scarcity', 'social-fairness']
    configs = ['full-system', 'no-metagoals', 'no-antigoals', 'baseline-m2']

    metrics = []
    for scenario in scenarios:
        for config in configs:
            # Simulate different outcomes for different configs
            hard_viols = 0 if config != 'no-antigoals' else 2
            soft_viols = 1 if 'antigoals' in config else 5
            goal_sat = 0.8 if config == 'full-system' else 0.6

            metrics.extend([
                MetricRecord(scenario, config, 'goal-satisfaction-after', goal_sat),
                MetricRecord(scenario, config, 'hard-violation-count', float(hard_viols)),
                MetricRecord(scenario, config, 'soft-violation-count', float(soft_viols)),
                MetricRecord(scenario, config, 'decision-latency-ms', 15.0),
                MetricRecord(scenario, config, 'metagoal-contribution-total', 0.2),
                MetricRecord(scenario, config, 'antigoal-penalty-total', 0.3),
                MetricRecord(scenario, config, 'plan-length', 3.0),
            ])

    return metrics


if __name__ == '__main__':
    sys.exit(main())
