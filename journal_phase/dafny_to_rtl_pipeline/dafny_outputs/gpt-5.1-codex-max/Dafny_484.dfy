module InsertionSort {

  predicate sorted(s: seq<int>)
    reads {}
  {
    forall i, j :: 0 <= i < j < |s| ==> s[i] <= s[j]
  }

  method InsertionSort(a: array<int>)
    requires a != null
    modifies a
    ensures sorted(a[..])
    ensures multiset(a[..]) == old(multiset(a[..]))
  {
    var n := a.Length;
    var i := 0;
    while i < n
      invariant 0 <= i <= n
      invariant sorted(a[..i])
      invariant forall j, k :: 0 <= j < i <= k < n ==> a[j] <= a[k]
      invariant multiset(a[..]) == old(multiset(a[..]))
      decreases n - i
    {
      var minIdx := i;
      var j := i + 1;
      while j < n
        invariant i + 1 <= j <= n
        invariant i <= minIdx < n
        invariant forall k :: i <= k < j ==> a[minIdx] <= a[k]
        invariant sorted(a[..i])
        invariant forall p, q :: 0 <= p < i <= q < n ==> a[p] <= a[q]
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
}
