module Sorter {

  predicate sorted(s: seq<int>)
  {
    forall i, j :: 0 <= i < j < |s| ==> s[i] <= s[j]
  }

  predicate bordered(s: seq<int>)
  {
    |s| == 0 || s[0] <= s[|s| - 1]
  }

  method Sort(a: array<int>)
    requires a != null
    requires bordered(a[..])
    modifies a
    ensures sorted(a[..])
    ensures bordered(a[..])
  {
    var n := a.Length;
    var i := 0;
    while i < n
      invariant 0 <= i <= n
      invariant sorted(a[..i])
      invariant forall k, j :: 0 <= k < i <= j < n ==> a[k] <= a[j]
    {
      var min := i;
      var j := i + 1;
      while j < n
        invariant i < j <= n
        invariant i <= min < j
        invariant forall k :: i <= k < j ==> a[min] <= a[k]
      {
        if a[j] < a[min] {
          min := j;
        }
        j := j + 1;
      }

      if i != min {
        var tmp := a[i];
        a[i] := a[min];
        a[min] := tmp;
      }

      i := i + 1;
    }
  }
}
