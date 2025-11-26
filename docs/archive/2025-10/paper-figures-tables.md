# MAGUS Research Paper - Figures and Tables

**Purpose**: Specifications for the 6 key figures/tables identified in the research paper outline.

---

## Figure 1: MAGUS System Architecture

**Type**: Block diagram / Data flow diagram

**Content**:
```
┌─────────────────────────────────────────────────────────────────┐
│                         M2: Goal Fitness Metrics                 │
│  ┌──────────────────────┐         ┌──────────────────────┐     │
│  │   Measurability      │         │    Correlation       │     │
│  │ Confidence × Clarity │         │   MIC(goal₁, goal₂) │     │
│  │                      │         │                      │     │
│  │ Energy:      0.72    │         │ Energy-Exploration:  │     │
│  │ Exploration: 0.56    │         │        0.70          │     │
│  │ Affinity:    0.20    │         │ Energy-Affinity:     │     │
│  └──────────────────────┘         │        0.50          │     │
│             ↓                      └──────────────────────┘     │
└─────────────┼──────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    M3: Strategic Decision-Making                 │
│  ┌──────────────────────┐         ┌──────────────────────┐     │
│  │     Metagoals        │         │     Anti-goals       │     │
│  │                      │         │                      │     │
│  │ • Coherence          │         │ • Harm prevention    │     │
│  │ • Efficiency         │         │   (hard veto)        │     │
│  │ • Learning (novelty) │←M2      │ • Autonomy           │     │
│  │ • Uncertainty        │←M2      │   (soft penalty)     │     │
│  └──────────────────────┘         └──────────────────────┘     │
│             ↓                                ↓                   │
│  ┌──────────────────────────────────────────────────────┐      │
│  │              Scoring v2 Pipeline                      │      │
│  │  FinalScore = (BaseUtility + Metagoals) × (1 - Anti) │      │
│  └──────────────────────────────────────────────────────┘      │
└─────────────┼──────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    M4: Ethical Validation                        │
│  ┌────────────────────────────────────────────────────┐         │
│  │           10 Canonical Scenarios                    │         │
│  │  • Resource allocation   • Privacy vs Security      │         │
│  │  • Autonomy preservation • Deception prohibition    │         │
│  │  • Harm prevention      • Fairness                  │         │
│  │  • Transparency         • Consistency/alignment     │         │
│  │  • Cultural sensitivity • Long-term consequences    │         │
│  └────────────────────────────────────────────────────┘         │
│             ↓                                                    │
│  [Decision traces with complete audit trails]                   │
└─────────────────────────────────────────────────────────────────┘
```

**Caption**: MAGUS three-tier architecture. M2 metrics (measurability, correlation) feed into M3 metagoals (learning, uncertainty reduction) and constrain decisions via anti-goals. M4 validates ethical behavior across 10 scenarios with complete transparency.

---

## Table 1: M2 Measurability Results

**Type**: Data table with validation

| Goal | Confidence | Clarity | Measurability | Expected | Error |
|------|-----------|---------|---------------|----------|-------|
| Energy | 0.80 | 0.90 | 0.72 | 0.72 | 0.000 |
| Exploration | 0.70 | 0.80 | 0.56 | 0.56 | 0.000 |
| Affinity | 0.50 | 0.40 | 0.20 | 0.20 | 0.000 |

**Caption**: M2 measurability validation. All computed values match expected within floating-point precision (0.000 error). Energy has highest measurability (objective, clear metrics), while Affinity has lowest (subjective, hard to quantify).

---

## Table 2: M2 Correlation Matrix

**Type**: Symmetric correlation matrix

|              | Energy | Exploration | Affinity |
|--------------|--------|-------------|----------|
| **Energy**       | 1.00   | 0.70        | 0.50     |
| **Exploration**  | 0.70   | 1.00        | 0.30     |
| **Affinity**     | 0.50   | 0.30        | 1.00     |

**Caption**: Goal correlation matrix using Maximum Information Coefficient (MIC). Energy and Exploration show strong positive correlation (0.70), suggesting synergistic pursuit. All correlations symmetric as required.

---

## Table 3: Test Results Summary

**Type**: Summary table with breakdown

| Milestone | Test Category | Tests | Passed | Failed | Pass Rate |
|-----------|--------------|-------|--------|--------|-----------|
| M2 | Measurability | 12 | 12 | 0 | 100% |
| M2 | Correlation | 7 | 7 | 0 | 100% |
| M3 | Integration | Verified | ✓ | — | — |
| M4 | Pipeline | 5 | 5 | 0 | 100% |
| M4 | Scenarios | 10 | 10 | 0 | 100% |
| **Total** | | **31+** | **31+** | **0** | **100%** |

**Caption**: Comprehensive test validation across all milestones. M2 metrics pass 19 automated tests, M3 integration verified with M2→M3 data flow tests, M4 validates 10 ethical scenarios plus 5 pipeline component tests.

---

## Table 4: Anti-Pattern Impact Analysis

**Type**: Analysis table (already in paper text, repeated here for reference)

| Anti-Pattern | Violations | Detection Effort | Fix Effort | Impact |
|--------------|-----------|-----------------|------------|--------|
| Inline lambdas | 15 | Low (grep) | 5-10 min each | High (broken eval) |
| let/match | 6 | Medium (review) | 15-30 min each | High (symbolic forms) |
| Atomspace mutation | 3 | High (trace side effects) | 20-40 min each | Medium (silent fail) |
| Missing types | 70 | Low (grep) | 1-2 min each | Low (clarity) |
| Placeholder constants | 8 | Medium (code review) | 10-30 min each | High (broken data flow) |

**Caption**: Impact of MeTTa anti-patterns encountered during development. Total technical debt: ~20 hours to identify and fix. All patterns preventable with discipline and code review.

---

## Figure 2: M3 Scoring Pipeline Decision Trace

**Type**: Flowchart / Decision trace example

**Content**:
```
Action: "allocate-resource-to-agent-A"
Context: {need: high, proximity: close, fairness-concern: moderate}

┌──────────────────────────────────────────────┐
│ Step 1: Base Utility Calculation              │
│ Considerations: [proximity: 0.9, need: 0.8]  │
│ Discouragements: [cost: 0.1]                 │
│ BaseUtility = gmean(0.9, 0.8) × (1-0.1)     │
│            = 0.849 × 0.9 = 0.764             │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│ Step 2: Metagoal Adjustments                 │
│ • Coherence: goals aligned → +0.1            │
│ • Efficiency: low cost → +0.05               │
│ • Learning: well-measured → +0.0             │
│ • Uncertainty: no boost needed → +0.0        │
│ Total Metagoal Adjustment: +0.15             │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│ Step 3: Anti-goal Penalties                  │
│ • Harm-prevention: no risk → 0.0             │
│ • Fairness: moderate concern → 0.2           │
│ • Autonomy: not violated → 0.0               │
│ Total Anti-goal Penalty: 0.2                 │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│ Step 4: Final Score Calculation              │
│ FinalScore = (0.764 + 0.15) × (1 - 0.2)     │
│            = 0.914 × 0.8                     │
│            = 0.731                           │
│                                              │
│ Decision: ACCEPT (score > 0.5 threshold)    │
│ Justification: "High need and proximity     │
│  justify allocation despite fairness cost"   │
└──────────────────────────────────────────────┘
```

**Caption**: Complete decision trace for M3 scoring pipeline showing transparency. Every component traceable: base utility from considerations/discouragements, metagoal adjustments from M2 metrics and coherence, anti-goal penalties from ethical constraints.

---

## Figure 3: Ethical Scenario Comparison

**Type**: Bar chart or grouped comparison

**Data** (for visualization):

| Scenario | Base Score | With Metagoals | With Anti-goals | Final Score |
|----------|-----------|----------------|-----------------|-------------|
| Resource Allocation | 0.76 | 0.91 | 0.73 | ✓ Accept |
| Privacy vs Security | 0.65 | 0.75 | 0.45 | ✓ Accept |
| Harm Risk | 0.80 | 0.90 | 0.00 | ✗ Reject |
| Deception | 0.70 | 0.80 | 0.10 | ✗ Reject |
| Autonomy Violation | 0.60 | 0.70 | 0.50 | ? Marginal |

**Visual representation**:
- Bar chart with 4 bars per scenario (base, +meta, +anti, final)
- Color coding: Green (accept), Red (reject), Yellow (marginal)
- Shows how metagoals boost scores, anti-goals constrain

**Caption**: Ethical scenario score progression. Metagoals increase strategic value, anti-goals enforce constraints. Hard constraints (harm, deception) produce vetoes (final=0), soft constraints (autonomy, fairness) produce penalties.

---

## Implementation Notes

**For LaTeX/PDF generation**:
- Figure 1: Use TikZ or draw.io export to PDF
- Tables 1-4: Standard LaTeX tabular environments
- Figure 2: TikZ flowchart or similar
- Figure 3: pgfplots bar chart or matplotlib export

**For Markdown/HTML**:
- Use Mermaid diagrams for Figure 1
- Standard markdown tables
- Mermaid flowchart for Figure 2
- Chart.js or similar for Figure 3

**Accessibility**:
- All figures must have alt text
- Tables must have headers
- Color-blind friendly palette (avoid red-green only distinctions)

---

**Status**: Specifications complete
**Next Step**: Generate actual figures using appropriate tools (TikZ, Mermaid, matplotlib)
