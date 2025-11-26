# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a MeTTa-Magus project implementing a decision-making system using the MeTTa programming language. MeTTa (Meta Type Talk) is a meta-language designed for AGI applications with facilities for handling symbols, variables, types, substitutions, and pattern matching.

## Files Structure

- `magus.metta` - Main implementation containing:
  - Utility functions (product, gmean, epsilon)
  - Action definition system with considerations and discouragements
  - Decision scoring algorithm using geometric mean and product
  - Action selection logic (choose-best-action)
- `notes.metta` - Development notes and experimental code
- `README.md` - Standard GitLab template (not project-specific)

## MeTTa Language Basics

### Key Syntax Elements
- Functions defined with `(: name (-> Type))` for type signatures
- Implementation with `(= (function-name args) body)`
- Lists use S-expression syntax: `(item1 item2 item3)`
- Comments start with `;`
- Evaluation with `! (function-call)`

### Core Patterns in This Codebase
- **Field Accessors**: Pattern matching to extract data from structured atoms (e.g., `get-action-name`, `get-considerations`)
- **Functional Operations**: Heavy use of `map-atom`, `foldl-atom`, `filter-atom` for list processing
- **Structured Data**: Actions defined as `(Action name (Considerations values) (Discouragements values))`

## Architecture

### Decision System Components

1. **Action Definition** (`action-definition`):
   - Returns predefined actions (Talk, Rest, Explore)
   - Each action has considerations (positive factors) and discouragements (negative factors)

2. **Scoring Algorithm** (`decision-score`):
   - Uses geometric mean of considerations
   - Multiplies by product of discouragements
   - Formula: `gmean(considerations) * product(discouragements)`

3. **Action Selection** (`choose-best-action`):
   - Evaluates all actions using `score-all`
   - Finds maximum score with `max-score`
   - Returns action(s) with highest score (within epsilon tolerance)

### Mathematical Functions
- `product`: Multiplies all numbers in a list using `foldl-atom`
- `gmean`: Geometric mean calculation using `pow-math`
- `epsilon`: Small value (1e-16) for floating-point comparisons

## Development Commands

This project has no build system or package management. MeTTa files are interpreted directly.

### Running Code
- Execute expressions with `! (expression)` syntax within MeTTa files
- Main entry points:
  - `! (score-all)` - Get all action scores
  - `! (max-score)` - Get highest scoring action
  - `! (choose-best-action)` - Select best action

### Testing
- Test expressions are commented out in `notes.metta`
- Manual testing through evaluation expressions in the files
- No formal test framework identified

## Working with This Codebase

### Making Changes
- Modify action definitions in `action-definition` function
- Adjust scoring weights in considerations/discouragements arrays
- Test changes by evaluating relevant functions with `!` syntax

### Key Functions to Understand
- `decision-score`: Core algorithm for evaluating actions
- `choose-best-action`: Main selection logic with epsilon tolerance
- Field accessors (`get-action-name`, `get-considerations`, `get-discouragements`): Data extraction patterns

### MeTTa-Specific Considerations
- Functions are purely functional with immutable data
- Pattern matching is used extensively for data extraction  
- List operations use `map-atom`, `foldl-atom`, `filter-atom`
- Type signatures are declarative but not strictly enforced

\# Using Gemini CLI for Large Repository Analysis
When analyzing large repositories (whether code or documentation) or multiple files that might exceed context limits, use the Gemini CLI with its massive
context window. Use `gemini -p` to leverage Google Gemini's large context capacity. This is particularly useful for documentation repositories like this one, where you may need to analyze interconnected markdown files, cross-references, or entire knowledge bases.
\## File and Directory Inclusion Syntax
Use the `@` syntax to include files and directories in your Gemini prompts. The paths should be relative to WHERE you run the
&nbsp; gemini command:
\### Examples:
\*\*Single file analysis:\*\*
gemini -p "@src/main.py Explain this file's purpose and structure"
Multiple files:
gemini -p "@package.json @src/index.js Analyze the dependencies used in the code"
Entire directory:
gemini -p "@src/ Summarize the architecture of this codebase"
Multiple directories:
gemini -p "@src/ @tests/ Analyze test coverage for the source code"
Current directory and subdirectories:
gemini -p "@./ Give me an overview of this entire project"
\# Or use --all\_files flag:
gemini --all\_files -p "Analyze the project structure and dependencies"
Repository Analysis Examples
\### Code Implementation Examples:
Check if a feature is implemented:
gemini -p "@src/ @lib/ Has dark mode been implemented in this codebase? Show me the relevant files and functions"
Verify authentication implementation:
gemini -p "@src/ @middleware/ Is JWT authentication implemented? List all auth-related endpoints and middleware"
\### Documentation Analysis Examples:
Analyze game faction relationships:
gemini -p "@docs/games/butterfly-galaxii/major-factions/ How do the different factions relate to each other? Create a relationship map"
Check documentation completeness:
gemini -p "@docs/games/godsgame/ Which pantheons or gods are missing detailed descriptions? List incomplete sections"
Find cross-references:
gemini -p "@docs/neoterics/ How do MAGUS, MeTTa, and OpenPsi frameworks relate to each other? Show all cross-references"
Analyze knowledge structure:
gemini -p "@docs/games/ @docs/notes/ What are the main themes and concepts across both game projects?"
Verify documentation consistency:
gemini -p "@docs/games/butterfly-galaxii/major-species/ @docs/games/butterfly-galaxii/major-factions/ Are species representations consistent across faction descriptions?"
Extract world-building elements:
gemini -p "@docs/games/butterfly-galaxii/tech/ @docs/games/butterfly-galaxii/gm/future-tech/ Summarize all technology concepts and their implications"
Check for documentation gaps:
gemini -p "@docs/business-plan/ @docs/neoterics/ How well does the business plan align with the technical AI/AGI research? Identify gaps"
When to Use Gemini CLI
Use gemini -p when:
\- Analyzing entire repositories (code or documentation)
\- Comparing multiple large files or documentation sections
\- Need to understand project-wide patterns, themes, or architecture
\- Current context window is insufficient for the task
\- Working with files totaling more than 100KB
\- Analyzing interconnected documentation (like game lore, factions, species relationships)
\- Checking documentation completeness or consistency across sections
\- Extracting insights from large knowledge bases
\- Finding cross-references between different documentation areas
\- Verifying if specific features, patterns, or concepts are implemented or documented
Important Notes
\- Paths in @ syntax are relative to your current working directory when invoking gemini
\- The CLI will include file contents directly in the context
\- No need for --yolo flag for read-only analysis
\- Gemini's context window can handle entire repositories (code or documentation) that would overflow Claude's context
\- When analyzing documentation, be specific about relationships, themes, or patterns you're looking for
\- For this Magi repository, consider analyzing entire game sections or cross-referencing between games and AI research