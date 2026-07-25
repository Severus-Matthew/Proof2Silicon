method Reverse(a: array<int>)
  requires a != null
  modifies a
  ensures forall i :: 0 <= i < a.Length ==> a[i] == old(a[a.Length - 1 - i])
{
  var n := a.Length;
  var i := 0;
  while i < n / 2
    invariant 0 <= i <= n / 2
    invariant forall k :: 0 <= k < i ==> a[k] == old(a[n - 1 - k])
    invariant forall k :: n - i <= k < n ==> a[k] == old(a[n - 1 - k])
    invariant forall k :: i <= k < n - i ==> a[k] == old(a[k])
    decreases n / 2 - i
  {
    var j := n - 1 - i;
    var tmp := a[i];
    a[i] := a[j];
    a[j] := tmp;
    i := i + 1;
  }
}
