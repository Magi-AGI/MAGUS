# Outstanding Issues after Claude’s M2/M3/M4 updates (2025-10-23)

## Major Findings
- (Import system) `test-m3-integration.metta`, `Milestone_3/tests/test-scoring-v2.metta`, and `Milestone_3/tests/test-planner.metta` still call `!(import! …)` with literal paths (`Milestone_2/…`, `../core/…`). Hyperon treats these as illegal module names, so the tests do not execute.
- (Scenario schema) `Milestone_4/ethical/scenarios.metta` redeclares `Context` and invokes `context test-lab …`, which clashes with the core context type and throws `IncorrectNumberOfArguments`. The pipeline runner logs the error yet prints “PASS” because no assertion is made on the return value.
- (Ethical runner placeholders) `Milestone_4/ethical/scenario-runner.metta` still returns raw goals from `apply-metagoals-to-context` and uses `simple-candidate-score`/`candidate-score` instead of the Milestone-3 scoring pipeline. As a result, metagoal adjustments and anti-goal penalties never influence the scenarios, and evaluation results are static defaults.
- (Planner tests) `Milestone_3/tests/test-planner.metta` still asserts against `(Action …)` structures even though `planner-bt.metta` now returns `BTAction` nodes.
- (Research paper) `MAGUS-Research-Paper-Draft.md` claims “31/31 tests passing” and fully functioning metagoal behavior, which contradicts current runtime errors and placeholders.

## Suggested Fixes
1. Replace all path-based `!(import!)` calls with either `!(load …)` or `register-module!`/`import!` sequences, then re-run the MeTTa test suite.
2. Adjust the ethical scenario schema so it does not redefine `Context` (e.g., introduce `scenario-context`), and make the Python regression runner assert on registration results to surface failures.
3. Connect the scenario runner to the real Milestone-3 pipeline: reuse `evaluate-all-metagoals`, `score-all-candidates`, `select-best-candidate`, etc., so metagoal/anti-goal logic actually affects outcomes.
4. Update planner tests to expect the `BTAction` structures produced by `planner-bt.metta`.
5. Revise the research-paper draft once the implementation and tests genuinely pass; until then, temper claims about coverage and strategic behavior.
