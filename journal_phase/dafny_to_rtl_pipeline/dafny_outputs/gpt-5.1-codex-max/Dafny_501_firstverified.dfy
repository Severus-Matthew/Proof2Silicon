// A complete, self-contained Dafny program that implements and verifies selection sort.
// The implementation avoids recursion and uses careful specifications (preconditions,
// postconditions), loop invariants, and assertions to justify correctness.
//
// The main correctness condition is that the output array is sorted. We also show
// that the algorithm does not change the multiset of elements (it is a permutation
// of the original array), which is a typical property of a correct sorting routine.

predicate IsSorted(s: seq<int>)
  // A simple sortedness predicate on sequences: every earlier element is <= any later element.
  // The quantifier says: for all indices i, j with i <= j in range, s[i] <= s[j].
{
  forall i: int, j: int :: 0 <= i <= j < |s| ==> s[i] <= s[j]
}

method Swap(a: array<int>, i: int, j: int)
  requires a != null
  requires 0 <= i < a.Length
  requires 0 <= j < a.Length
  modifies a
  ensures a[i] == old(a[j]) && a[j] == old(a[i]) // values at i and j are swapped
  ensures forall k: int :: 0 <= k < a.Length && k != i && k != j ==> a[k] == old(a[k]) // other elements unchanged
  ensures multiset(a[..]) == multiset(old(a[..])) // swapping preserves the multiset of elements
{
  // Save one of the elements temporarily.
  var tmp := a[i];
  // Perform the swap of elements at positions i and j.
  a[i] := a[j];
  a[j] := tmp;

  // Because we have only swapped two elements and left all others unchanged,
  // the multiset of elements in the array is preserved. This is captured by
  // the last postcondition.
}

method SelectionSort(a: array<int>)
  requires a != null
  modifies a
  ensures IsSorted(a[..])                         // The resulting array is sorted
  ensures multiset(a[..]) == multiset(old(a[..])) // The elements are a permutation of the input
{
  // Capture the multiset of the input in a ghost variable to reason about permutations.
  ghost var ms0 := multiset(a[..]);

  var i := 0;
  // Outer loop: iterate over each position in the array and place the correct element there.
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant IsSorted(a[..i]) // The prefix [0..i) is sorted
    invariant forall k: int, m: int :: 0 <= k < i <= m < a.Length ==> a[k] <= a[m] // All elements in the sorted prefix are <= all elements in the suffix
    invariant multiset(a[..]) == ms0 // The multiset of elements is preserved
    decreases a.Length - i
  {
    // Find the index of the minimal element in the suffix starting at i.
    var minIndex := i;
    var j := i + 1;
    while j < a.Length
      invariant i <= minIndex < a.Length      // minIndex is always a valid index in [i..)
      invariant i < j <= a.Length             // j ranges from i+1 up to Length
      invariant forall k: int :: i <= k < j ==> a[minIndex] <= a[k] // a[minIndex] is <= every element examined so far in the suffix
      invariant multiset(a[..]) == ms0        // No modifications here; multiset stays the same
      decreases a.Length - j
    {
      if a[j] < a[minIndex] {
        minIndex := j;
      }
      j := j + 1;
    }
    // At loop exit, j == a.Length and minIndex points to a minimum element in the suffix [i..).
    assert forall k: int :: i <= k < a.Length ==> a[minIndex] <= a[k];

    // Save some values for reasoning.
    ghost var minVal := a[minIndex];
    ghost var oldIVal := a[i];

    // Swap the minimal element into position i.
    Swap(a, i, minIndex);

    // After the swap, a[i] holds the minimum element of the old suffix,
    // and all other elements remain the same multiset-wise.
    assert a[i] == minVal;

    // Show that extending the sorted prefix by a[i] keeps it sorted:
    // - The previous prefix [0..i) was sorted by invariant.
    // - Every element in the previous prefix is <= any element in the old suffix (and thus <= the new a[i]).
    assert forall k: int :: 0 <= k < i ==> a[k] <= a[i];

    // Show that the new element a[i] is <= any element in the remaining suffix (positions > i).
    assert forall k: int :: i < k < a.Length ==> a[i] <= a[k];

    // With these facts, we can argue that the prefix [0..i+1) is sorted.
    assert IsSorted(a[..(i+1)]);

    // Also show that the updated prefix elements are still <= the remaining suffix.
    assert forall k: int, m: int :: 0 <= k < i+1 <= m < a.Length ==> a[k] <= a[m];

    // Increase i to extend the sorted prefix in the next iteration.
    i := i + 1;
  }

  // At loop exit, i == a.Length and the invariant IsSorted(a[..i]) implies the whole array is sorted.
  assert i == a.Length;
  assert IsSorted(a[..]);

  // The multiset invariant guarantees the result is a permutation of the input.
  assert multiset(a[..]) == ms0;
}
