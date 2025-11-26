# MAGUS – Anna Feedback Follow-Up (2025-10-08)

## Assessment Recap

- **Measurability-Weighted Correlation**
  - Spec already defines the updated formula (`Metrics-Specification-v1.md:195`), and `get-weighted-correlation` in `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta:138` implements it.
  - The "Overgoal" layer never calls that helper; `magus.metta` is still the old arousal-biased prototype, so the advertised overgoal computation is missing in practice.

- **Modulators**
  - Docs promise PAD + Bach’s six attentional modulators (pleasure, arousal, dominance; focus, resolution, exteroception) per `Core Framework Design Document (AM).md:326-366`.
  - Runtime (`Milestone_3/core/scoring-v2.metta:57-62`) only recognizes four modulators: arousal, pleasure, dominance, focus. Resolution and exteroception/activation are absent.
  - The M2 milestone doc’s TC3.1 cites “Energy level 0.9, Arousal 0.8, Focus 0.7”, but the referenced test (`Milestone_2/Testing_scenario/goal-ranking-test.metta`) is still urgency × importance with no modulator inputs, so the write-up and executable diverge.

- **End-to-End Progression Test**
  - No single test executes Anna’s desired flow (context ? measurabilities ? correlations ? modulators ? rank ? select). `test-m2-m3-integration.py` only spot-checks numeric results and antigoal costs.

- **Legacy Tests**
  - Existing goal-ranking tests (MeTTa/Python) still mirror the old `weight = importance * urgency` formula and don’t validate the new pipeline.

## Recommendations

1. **Adopt Bach’s Six Modulators**
   - Extend `modulator-effect` in `Milestone_3/core/scoring-v2.metta` to handle `resolution` and `exteroception` (and update any data structures or helper functions accordingly).
   - Update context builders, AIRIS integration, and tests to populate all six modulators. Ensure docs specify the expected ranges/effects with the new names.

2. **Clarify and Implement the Overgoal Calculation**
   - Rename functions/variables around weighted correlation to make the "Overgoal" purpose explicit (e.g., `calculate-overgoal-correlation`, `overgoal-score`).
   - Integrate those helpers into the high-level decision flow (likely in `scoring-v2.metta` or a dedicated overgoal module) so we actually compute the overgoal value using the averaged measurability-weighted correlation formula.
   - Document the overgoal pipeline in both `README.md` and `MAGUS-Best-Practices.md`, including input signals, formula, and usage.

3. **Align Documentation and Code**
   - Revise milestone reports and scenario write-ups to match the six-modulator design and the new overgoal implementation once coded.
   - Remove references to “energy level as modulator” unless we formalize it as a separate state variable; otherwise highlight the PAD/attentional modulators we do support.

4. **Add Comprehensive Regression Tests**
   - Replace/augment `goal-ranking-test.metta` (and its Python twin) with a scenario that:
     1. Loads a context containing current goal states and all modulators.
     2. Recomputes measurabilities (calling the MeTTa code).
     3. Recomputes correlations.
     4. Applies modulator effects.
     5. Ranks goals by combined fitness / overgoal metric.
     6. Asserts that the top-ranked goal matches expectations.
   - Add coverage ensuring resolution/exteroception modifiers influence scores as intended.

5. **Update Knowledge-Repo Materials**
   - After code changes, sync `Core Framework Design Document`, `Milestone-3/4 plans`, and `MAGUS-Best-Practices.md` to the actual implementation (names, formulas, system diagrams).

Once these steps land, run the full suite under Hyperon in WSL and refresh the “31/31 tests passing” claims with real results.
