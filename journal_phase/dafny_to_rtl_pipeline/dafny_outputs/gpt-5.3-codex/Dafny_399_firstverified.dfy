// 1. Reasoning about the logic and specification:
//    - Focus on arithmetic properties over natural numbers and integers, especially for powers and logarithm-like bounds.
//    - Specify exact postconditions (equalities/inequalities) and preconditions that ensure operations are well-defined
//      (e.g., non-zero divisors, base >= 2 for logarithmic reasoning).
//    - For logarithm-style results, specify bounds of the form:
//         pow(base, k) <= n < pow(base, k+1)
//      rather than trying to encode a complicated exact algebraic identity.
//
// 2. Relevant Dafny constructs and their usage:
//    - Use `method` (not recursive `function`) with `while` loops to compute quantities like powers and integer logs.
//    - Add loop invariants that capture:
//         * variable ranges (e.g., 0 <= i <= k),
//         * algebraic meaning of accumulators,
//         * monotonic bounds needed for postconditions.
//    - Use `decreases` on loops (`decreases k - i`, etc.) for termination.
//    - Introduce helper lemmas for arithmetic monotonicity if the verifier needs intermediate facts.
//    - Use `assert` statements at key points to guide SMT solving.
//
// 3. Potential edge cases and how to handle them:
//    - Handle n = 0 and n = 1 explicitly for logarithm-like methods.
//    - Require `base >= 2` for meaningful growth and to avoid non-termination/degenerate behavior.
//    - Ensure multiplication does not rely on machine overflow assumptions (Dafny integers are mathematical, so this is safe).
//    - Guard divisions/mods with non-zero denominator preconditions.
//
// 4. Final suggestions or reminders to avoid common pitfalls:
//    - Avoid recursion entirely (including recursive functions and lemmas); use iterative methods/lemmas with loops.
//    - Keep specs consistent with implementation domains (`nat` vs `int`).
//    - Strengthen invariants early if proof fails; weak invariants are the most common issue.
//    - Avoid underspecified returns; every returned value should be constrained by ensures clauses.
//
// 5. Guidance that helps the verifier prove the program successfully:
//    - Prove properties incrementally: first establish loop accumulator meaning, then derive final bounds.
//    - Add small helper assertions after updates, e.g., after `p := p * base`, assert the expected relation.
//    - If a postcondition involves strict inequalities, encode and preserve them in invariants through each loop step.
//    - Prefer linear arithmetic-friendly formulations and explicit bounds to reduce SMT search complexity.
//
// 6. Avoid recursion in the code:
//    - Implement all computations (power/log/bounds) with iterative loops only.
//    - Any proof support should use non-recursive lemmas/methods with loop-based reasoning.
//
// 7. Return only the instruction for the coding agent.
