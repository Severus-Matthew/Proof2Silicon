module Foo {

  method Reverse(a: array<int>)
    modifies a
    ensures a.Length == old(a.Length)
    ensures forall i :: 0 <= i < a.Length ==> a[i] == old(a[a.Length - 1 - i])
  {
    ghost var pre := a[..];
    var i := 0;
    var j := a.Length - 1;
    while i < j
      invariant 0 <= i <= j + 1 <= a.Length
      invariant i + j == a.Length - 1
      invariant forall k :: 0 <= k < i ==> a[k] == pre[|pre| - 1 - k]
      invariant forall k :: j < k < a.Length ==> a[k] == pre[|pre| - 1 - k]
      invariant forall k :: i <= k <= j ==> a[k] == pre[k]
      decreases j - i
    {
      var tmp := a[i];
      a[i] := a[j];
      a[j] := tmp;
      i := i + 1;
      j := j - 1;
    }
  }

  method Foo(a: array<int>, b: int)
    requires a.Length > 0
    ensures a.Length == old(a.Length) && a[0] == old(a[0]) && a[a.Length - 1] == old(a[a.Length - 1]) && a[0] * b == old(a[0] * b)
    ensures forall i :: 0 <= i < a.Length ==> a[i] == old(a[i])
    modifies a
  {
    // Intentionally left blank; array 'a' is not modified.
  }
}
