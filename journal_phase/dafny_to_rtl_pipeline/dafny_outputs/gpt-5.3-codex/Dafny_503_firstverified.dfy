module Partitioning {

  method Partition(a: array<int>, lo: int, hi: int) returns (p: int)
    requires a != null
    requires 0 <= lo < hi <= a.Length
    modifies a
    ensures lo <= p < hi
    ensures forall i :: lo <= i < p ==> a[i] <= a[p]
    ensures forall i :: p < i < hi ==> a[i] > a[p]
    ensures forall i :: 0 <= i < lo ==> a[i] == old(a[i])
    ensures forall i :: hi <= i < a.Length ==> a[i] == old(a[i])
  {
    var pivot := a[hi - 1];
    var i := lo;
    var j := lo;

    while j < hi - 1
      invariant lo <= i <= j <= hi - 1
      invariant forall k :: lo <= k < i ==> a[k] <= pivot
      invariant forall k :: i <= k < j ==> a[k] > pivot
      invariant a[hi - 1] == pivot
      invariant forall k :: 0 <= k < lo ==> a[k] == old(a[k])
      invariant forall k :: hi <= k < a.Length ==> a[k] == old(a[k])
      decreases hi - 1 - j
    {
      if a[j] <= pivot {
        var t := a[i];
        a[i] := a[j];
        a[j] := t;
        i := i + 1;
      }
      j := j + 1;
    }

    assert lo <= i <= hi - 1;
    var t2 := a[i];
    a[i] := a[hi - 1];
    a[hi - 1] := t2;
    p := i;

    assert forall k :: lo <= k < p ==> a[k] <= a[p];
    assert forall k :: p < k < hi ==> a[k] > a[p];
  }
}
