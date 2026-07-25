// Use the following Dafny constructs to achieve the desired functionality:
// method, requires, ensures, modifies, while, invariant, decreases, assert, ghost variables, sequences, arrays.

// This example demonstrates safe in-place reversal of an integer array without recursion.
// It includes detailed specifications, loop invariants, assertions, and a clear termination argument.
method ReverseInPlace(a: array<int>)
  requires a != null
  modifies a
  ensures a.Length == old(a.Length)
  ensures forall i :: 0 <= i < a.Length ==> a[i] == old(a[a.Length - 1 - i])
{
  // Ghost snapshot of the original array content for reasoning in loop invariants.
  ghost var oldSeq := a[..];

  var i := 0;
  var j := a.Length - 1;

  // Loop swaps symmetric elements from both ends toward the center.
  while i < j
    invariant 0 <= i <= a.Length
    invariant -1 <= j < a.Length || a.Length == 0
    invariant i + j == a.Length - 1
    // Left processed segment is already in final reversed position.
    invariant forall k :: 0 <= k < i ==> a[k] == oldSeq[a.Length - 1 - k]
    // Right processed segment is already in final reversed position.
    invariant forall k :: j < k < a.Length ==> a[k] == oldSeq[a.Length - 1 - k]
    // Middle segment remains equal to original for not-yet-swapped positions.
    invariant forall k :: i <= k <= j ==> a[k] == oldSeq[k]
    decreases j - i
  {
    // Basic bounds facts from loop guard and invariants.
    assert 0 <= i < a.Length;
    assert 0 <= j < a.Length;

    // Swap a[i] and a[j].
    var t := a[i];
    a[i] := a[j];
    a[j] := t;

    i := i + 1;
    j := j - 1;
  }

  // After loop, every index is in final reversed position.
  assert forall k :: 0 <= k < a.Length ==> a[k] == oldSeq[a.Length - 1 - k];
}

// Small utility showing usage and edge cases (empty and singleton arrays are naturally handled).
method Demo()
{
  var a := new int[5];
  a[0], a[1], a[2], a[3], a[4] := 10, 20, 30, 40, 50;

  ReverseInPlace(a);

  // Expected reversed content.
  assert a[0] == 50;
  assert a[1] == 40;
  assert a[2] == 30;
  assert a[3] == 20;
  assert a[4] == 10;

  // Edge case: empty array.
  var e := new int[0];
  ReverseInPlace(e);
  assert e.Length == 0;

  // Edge case: single element.
  var s := new int[1];
  s[0] := 7;
  ReverseInPlace(s);
  assert s[0] == 7;
}
