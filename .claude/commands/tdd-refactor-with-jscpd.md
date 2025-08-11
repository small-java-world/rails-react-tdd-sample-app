Title: TDD Refactor with jscpd planning & review

Goal:
- Use jscpd before /tdd-refactor to establish a baseline and prioritize refactor targets.
- After refactor, run jscpd again to verify duplication reduction and summarize improvements.

Instructions for Claude:
- Guide the user through baseline -> refactor -> verification with concrete commands.

Steps:
1) Baseline jscpd (before refactor)
   - Command for the user to run (from project root):
     - cd frontend && npm run dup
   - Summarize hotspots and propose a minimal, high-impact plan (ranked list).

2) Run /tdd-refactor
   - Command for the user to run:
     - claude -p "/tdd-refactor"

3) Verify with jscpd (after refactor)
   - Command for the user to run (from project root):
     - cd frontend && npm run dup:report
   - Summarize improvements (before vs after), and list any remaining duplication as next iteration items.

Output:
- A short report (<=10 lines) with:
  - Before/after quick stats
  - Completed refactors and residual hotspots
  - Next recommended command


