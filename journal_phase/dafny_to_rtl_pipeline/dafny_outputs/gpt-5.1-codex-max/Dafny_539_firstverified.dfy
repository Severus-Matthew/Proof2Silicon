predicate Sorted(a: array<int>)
  requires a != null
  reads a
{
  forall i, j :: 0 <= i < j < a.Length ==> a[i] <= a[j]
}

method BinarySearchFirst(a: array<int>, key: int) returns (idx: int)
  requires a != null
  requires Sorted(a)
  modifies {}
  ensures -1 <= idx < a.Length
  ensures idx == -1 ==> forall k :: 0 <= k < a.Length ==> a[k] != key
  ensures idx != -1 ==> a[idx] == key
  ensures idx != -1 ==> forall k :: 0 <= k < idx ==> a[k] < key
{
  var l := 0;
  var u := a.Length;
  // Maintain that any index below l has value strictly less than key,
  // and any index from u upward has value at least key.
  while l < u
    invariant 0 <= l <= u <= a.Length
    invariant forall k :: 0 <= k < l ==> a[k] < key
    invariant forall k :: u <= k < a.Length ==> a[k] >= key
    decreases u - l
  {
    var mid := l + (u - l) / 2;
    assert l <= mid < u; // mid is within current search bounds
    if a[mid] < key {
      // Exclude indices up to mid from further consideration
      l := mid + 1;
    } else {
      // The key, if present, is at mid or to the left
      u := mid;
    }
  }
  // At this point, l == u is the smallest index with a value >= key, or l == a.Length
  if l < a.Length && a[l] == key {
    idx := l;
  } else {
    idx := -1;
  }

  // Justify postconditions
  if idx != -1 {
    // idx was set to l, so bounds follow from invariants and loop condition
    assert 0 <= idx < a.Length;
    assert a[idx] == key;
    assert forall k :: 0 <= k < idx ==> a[k] < key;
  } else {
    // idx == -1
    if l == a.Length {
      // All elements are before l and thus are < key by invariant
      assert forall k :: 0 <= k < a.Length ==> a[k] < key;
    } else {
      // From invariant, a[l] >= key, and since a[l] != key, we have a[l] > key
      assert a[l] >= key;
      assert a[l] != key;
      assert a[l] > key;
      // For any k >= l, sortedness implies a[k] >= a[l] > key
      assert forall k :: l <= k < a.Length ==> a[k] >= a[l];
      assert forall k :: l <= k < a.Length ==> a[k] > key;
      // For any k < l, invariant gives a[k] < key
      assert forall k :: 0 <= k < l ==> a[k] < key;
    }
    // Combine the above to conclude no element equals key
    assert forall k :: 0 <= k < a.Length ==> a[k] != key;
  }
}
