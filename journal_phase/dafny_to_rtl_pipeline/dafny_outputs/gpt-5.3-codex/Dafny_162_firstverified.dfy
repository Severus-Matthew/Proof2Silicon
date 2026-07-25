method Minimum(a: array<int>) returns (min: int)
  requires a != null
  requires a.Length > 0
  ensures forall i :: 0 <= i < a.Length ==> min <= a[i]
{
  var idx := 0;
  min := a[0];

  while idx < a.Length
    invariant 0 <= idx <= a.Length
    invariant forall k :: 0 <= k < idx ==> min <= a[k]
    decreases a.Length - idx
  {
    if a[idx] < min {
      min := a[idx];
    }
    idx := idx + 1;
  }
}
