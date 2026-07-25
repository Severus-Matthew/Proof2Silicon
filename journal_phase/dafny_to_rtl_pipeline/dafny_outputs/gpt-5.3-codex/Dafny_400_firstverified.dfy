// Use the following Dafny constructs to achieve the desired logic and postconditions:
// method, requires, ensures, modifies, while, invariant, decreases, assert, ghost variables, and sequence slices.

method ReverseCopy(a: array<int>) returns (b: array<int>)
  requires a != null
  ensures b != null
  ensures b.Length == a.Length
  ensures forall i :: 0 <= i < a.Length ==> b[i] == a[a.Length - 1 - i]
{
  // Allocate result array with matching length.
  b := new int[a.Length];

  var i := 0;

  // Step-by-step reasoning intent:
  // 1) Build b from left to right.
  // 2) At each step i, establish that all positions < i satisfy the reverse relation.
  // 3) Preserve bounds and progress to termination.
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant b != null && b.Length == a.Length
    invariant forall k :: 0 <= k < i ==> b[k] == a[a.Length - 1 - k]
    decreases a.Length - i
  {
    // Assign next reversed element.
    b[i] := a[a.Length - 1 - i];

    // Local sanity checks to make proof obligations explicit.
    assert 0 <= i < a.Length;
    assert 0 <= a.Length - 1 - i < a.Length;
    assert b[i] == a[a.Length - 1 - i];

    i := i + 1;
  }

  // Final postcondition bridge from loop invariant.
  assert i == a.Length;
  assert forall k :: 0 <= k < a.Length ==> b[k] == a[a.Length - 1 - k];

  // Reminder to avoid common pitfalls:
  // - Keep index arithmetic within bounds.
  // - Strengthen invariants enough to imply postconditions.
  // - Provide a strictly decreasing termination measure.
}
