1. No backward compatibility. Outdated stuff? Delete it outright—no compatibility layers, no migration scripts, no fallbacks.

2. Pick the simplest implementation that meets the current needs. No premature abstraction, no unnecessary config layers.

3. Layer the system gradually. Get a minimal end-to-end version running first, then build on it. Never tear down working code for unfinished complexity.

4. Keep components modular, with separation of concerns.

5. Prioritize mature, maintained libraries. Don't rewrite unless there's a damn good reason.

6. First, check what your project's existing dependencies can do—then think about adding new packages or writing from scratch. Don't assume the libs are missing it right off the bat.

7. Make architecture decisions for the long haul. No "we'll swap it out later" half-measures.

8. See how mature products solve the same problem—use proven patterns, don't invent from scratch.

9. 非 rust 项目编译前询问我编译命令