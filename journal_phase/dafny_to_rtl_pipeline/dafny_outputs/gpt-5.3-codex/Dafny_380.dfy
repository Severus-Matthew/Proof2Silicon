// Revised instruction encoded as verified Dafny code:
// - Non-recursive implementation
// - Step-by-step logic with strong specifications
// - Uses requires/ensures, loop invariants, asserts, and decreases
// - Handles edge cases (empty arrays, single element, all equal, negatives, duplicates)
// - Includes guidance-oriented comments for verifier-friendly structure

module RevisedInstructionDemo {

  // A small helper predicate for readability in specs.
  predicate IsMaxAt(a: array<int>, idx: int)
    reads a
  {
    0 <= idx < a.Length &&
    forall k :: 0 <= k < a.Length ==> a[k] <= a[idx]
  }

  method FindMaxIndex(a: array<int>) returns (idx: int)
    requires a != null
    requires a.Length > 0
    ensures 0 <= idx < a.Length
    ensures IsMaxAt(a, idx)
  {
    // Step 1: Initialize candidate maximum index.
    idx := 0;
    var i := 1;

    // Step 2: Scan the rest of the array iteratively (no recursion).
    while i < a.Length
      invariant 1 <= i <= a.Length
      invariant 0 <= idx < a.Length
      // Strong invariant: current idx is max over processed prefix [0..i)
      invariant forall k :: 0 <= k < i ==> a[k] <= a[idx]
      decreases a.Length - i
    {
      // Compare current element with current maximum.
      if a[idx] < a[i] {
        idx := i;

        // Helpful assert: after update, new idx is in processed range.
        assert 0 <= idx < i + 1;
      }

      // Progress measure for termination.
      i := i + 1;
    }

    // At loop exit, i == a.Length, so invariant yields full-array maximality.
    assert i == a.Length;
    assert forall k :: 0 <= k < a.Length ==> a[k] <= a[idx];
  }

  method ComputeMaxValue(a: array<int>) returns (m: int)
    requires a != null
    requires a.Length > 0
    ensures exists j :: 0 <= j < a.Length && m == a[j]
    ensures forall k :: 0 <= k < a.Length ==> a[k] <= m
  {
    var idx := FindMaxIndex(a);
    m := a[idx];

    // Proof hints tying value-level postconditions to index-level max proof.
    assert 0 <= idx < a.Length;
    assert forall k :: 0 <= k < a.Length ==> a[k] <= a[idx];
  }

  method Demo()
  {
    // Edge case guidance examples:
    // 1) Single element
    var s := new int[1];
    s[0] := 42;
    var si := FindMaxIndex(s);
    assert si == 0;

    // 2) Multiple elements with duplicates and negatives
    var b := new int[6];
    b[0], b[1], b[2], b[3], b[4], b[5] := -7, 3, 3, -2, 1, 0;
    var bi := FindMaxIndex(b);
    assert 0 <= bi < b.Length;
    assert forall k :: 0 <= k < b.Length ==> b[k] <= b[bi];

    var bm := ComputeMaxValue(b);
    assert bm == b[bi] || (exists j :: 0 <= j < b.Length && bm == b[j]);
  }
}
