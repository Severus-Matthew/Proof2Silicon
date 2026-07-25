method LinearSearch<T>(a: array<T>, p: T -> bool) returns (idx: int)
  requires a != null
  ensures -1 <= idx < a.Length
  ensures idx == -1 ==> (forall k :: 0 <= k < a.Length ==> !p(a[k]))
  ensures idx != -1 ==> 0 <= idx < a.Length && p(a[idx])
  ensures idx != -1 ==> (forall k :: 0 <= k < idx ==> !p(a[k]))
{
  var i := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall k :: 0 <= k < i ==> !p(a[k])
    decreases a.Length - i
  {
    if p(a[i]) {
      idx := i;
      return;
    } else {
      i := i + 1;
    }
  }
  idx := -1;
}
