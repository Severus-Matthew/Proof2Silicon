method MaxInArray(a: array<int>) returns (m: int)
  requires a != null
  requires a.Length > 0
  ensures forall i :: 0 <= i < a.Length ==> m >= a[i]
  ensures exists i :: 0 <= i < a.Length && m == a[i]
{
  var i := 1;
  m := a[0];

  while i < a.Length
    invariant 1 <= i <= a.Length
    invariant forall k :: 0 <= k < i ==> m >= a[k]
    invariant exists k :: 0 <= k < i && m == a[k]
    decreases a.Length - i
  {
    if a[i] > m {
      m := a[i];
    }
    i := i + 1;
  }
}
