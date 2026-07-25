module SelectionSortModule {

  predicate IsSorted(a: array<int>, lo: int, hi: int)
    requires a != null
    requires 0 <= lo <= hi <= a.Length
    reads a
  {
    forall i, j :: lo <= i < j < hi ==> a[i] <= a[j]
  }

  method SelectionSort(a: array<int>)
    requires a != null
    modifies a
    ensures IsSorted(a, 0, a.Length)
    ensures multiset(a[..]) == old(multiset(a[..]))
  {
    var n := a.Length;
    var i := 0;

    while i < n
      invariant 0 <= i <= n
      invariant IsSorted(a, 0, i)
      invariant forall p, q :: 0 <= p < i <= q < n ==> a[p] <= a[q]
      invariant multiset(a[..]) == old(multiset(a[..]))
      decreases n - i
    {
      var min := i;
      var j := i + 1;

      while j < n
        invariant i + 1 <= j <= n
        invariant i <= min < n
        invariant forall k :: i <= k < j ==> a[min] <= a[k]
        invariant IsSorted(a, 0, i)
        invariant forall p, q :: 0 <= p < i <= q < n ==> a[p] <= a[q]
        invariant multiset(a[..]) == old(multiset(a[..]))
        decreases n - j
      {
        if a[j] < a[min] {
          min := j;
        }
        j := j + 1;
      }

      if min != i {
        var tmp := a[i];
        a[i] := a[min];
        a[min] := tmp;
      }

      i := i + 1;
    }
  }
}
