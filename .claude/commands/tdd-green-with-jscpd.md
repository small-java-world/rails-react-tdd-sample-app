Title: TDD Green with jscpd review

Goal:
- Run /tdd-green for the current task, then run jscpd immediately to detect new duplication.
- Summarize findings and decide if a quick cleanup is needed or defer to /tdd-refactor.

Instructions for Claude:
- Execute the following steps with concise outputs and concrete next actions.

Steps:
1) Run TDD green phase
   - Command for the user to run:
     - claude -p "/tdd-green"
   - Wait for the green phase to complete (tests green, minimal implementation done).

2) Run jscpd immediately after green
   - Command for the user to run (from project root):
     - cd frontend && npm run dup && npm run dup:report
   - Collect the console output and summarize:
     - Clones found, duplicated lines %, hotspot files/ranges
   - Note HTML report location: reports/jscpd/html/index.html

3) Decide next action
   - If duplication is trivial and safe to address quickly (low risk), propose 1-2 minimal cleanups.
   - Otherwise defer to /tdd-refactor and note the hotspot to revisit.

Output:
- A short summary (<=10 lines) with:
  - jscpd quick stats
  - Suggested immediate cleanup or deferral note
  - Precise next command for the user (either proceed or refactor planning)


