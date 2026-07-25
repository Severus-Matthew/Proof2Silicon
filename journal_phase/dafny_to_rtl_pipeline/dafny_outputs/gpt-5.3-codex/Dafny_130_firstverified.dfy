module SelectionSortVerified {

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
        invariant multiset(a[..]) == old(multiset(a[..]))
        decreases n - j
      {
        if a[j] < a[min] {
          min := j;
        }
        j := j + 1;
      }

      if min != i {
        var t := a[i];
        a[i] := a[min];
        a[min] := t;
      }

      i := i + 1;
    }
  }

  method Main()
  {
    var a := new int[8];
    a[0] := 5;
    a[1] := 2;
    a[2] := 9;
    a[3] := 1;
    a[4] := 5;
    a[5] := 6;
    a[6] := 0;
    a[7] := 3;

    ghost var before := a[..];
    SelectionSort(a);

    assert IsSorted(a, 0, a.Length);
    assert multiset(a[..]) == multiset(before);
  }
}
