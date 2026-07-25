predicate isSorted(a: array<int>)
  reads a
{
  forall i, j :: 0 <= i <= j < a.Length ==> a[i] <= a[j]
}

method binarySearch(K: int, A: array<int>) returns (idx: int)
  requires A != null
  requires A.Length > 0
  requires isSorted(A)
  requires exists i :: 0 <= i < A.Length && A[i] == K
  ensures 0 <= idx < A.Length
  ensures A[idx] == K
{
  var lo := 0;
  var hi := A.Length - 1;

  while lo <= hi
    invariant 0 <= lo <= A.Length
    invariant -1 <= hi < A.Length
    invariant lo <= hi + 1
    invariant exists i :: lo <= i <= hi && A[i] == K
    decreases hi - lo + 1
  {
    var mid := lo + (hi - lo) / 2;
    assert lo <= mid <= hi;
    assert 0 <= mid < A.Length;

    if A[mid] == K {
      idx := mid;
      return;
    } else if A[mid] < K {
      assert forall i :: 0 <= i <= mid ==> A[i] <= A[mid];
      assert forall i :: 0 <= i <= mid ==> A[i] < K;
      lo := mid + 1;
      assert exists i :: lo <= i <= hi && A[i] == K;
    } else {
      assert forall i :: mid <= i < A.Length ==> A[mid] <= A[i];
      assert forall i :: mid <= i < A.Length ==> K < A[i];
      hi := mid - 1;
      assert exists i :: lo <= i <= hi && A[i] == K;
    }
  }

  // Unreachable due to precondition that K exists in A and loop invariants
  assert false;
  idx := 0;
}
