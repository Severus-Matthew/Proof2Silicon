module SortingExample {

  predicate IsSorted(a: array<int>)
    reads a
  {
    forall i, j :: 0 <= i < j < a.Length ==> a[i] <= a[j]
  }

  method SelectionSort(a: array<int>)
    modifies a
    ensures IsSorted(a)
    ensures multiset(a[..]) == old(multiset(a[..]))
  {
    var n := a.Length;
    var i := 0;

    while i < n
      invariant 0 <= i <= n
      invariant forall p, q :: 0 <= p < q < i ==> a[p] <= a[q]
      invariant forall p, q :: 0 <= p < i <= q < n ==> a[p] <= a[q]
      invariant multiset(a[..]) == old(multiset(a[..]))
      decreases n - i
    {
      var minIdx := i;
      var j := i + 1;

      while j < n
        invariant i + 1 <= j <= n
        invariant i <= minIdx < n
        invariant forall k :: i <= k < j ==> a[minIdx] <= a[k]
        invariant multiset(a[..]) == old(multiset(a[..]))
        decreases n - j
      {
        if a[j] < a[minIdx] {
          minIdx := j;
        }
        j := j + 1;
      }

      if minIdx != i {
        var tmp := a[i];
        a[i] := a[minIdx];
        a[minIdx] := tmp;
      }

      i := i + 1;
    }
  }

  method Test(a: array<int>)
    modifies a
    ensures IsSorted(a)
    ensures multiset(a[..]) == old(multiset(a[..]))
  {
    SelectionSort(a);
  }
}
