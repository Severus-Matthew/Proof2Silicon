method MaxElement(a: array<int>) returns (m: int, idx: int)
  requires a != null
  requires a.Length > 0
  ensures 0 <= idx < a.Length
  ensures m == a[idx]
  ensures forall j :: 0 <= j < a.Length ==> a[j] <= m
{
  var i := 1;
  idx := 0;
  m := a[0];

  while i < a.Length
    invariant 1 <= i <= a.Length
    invariant 0 <= idx < i
    invariant m == a[idx]
    invariant forall j :: 0 <= j < i ==> a[j] <= m
    decreases a.Length - i
  {
    if a[i] > m {
      m := a[i];
      idx := i;
    }
    assert 0 <= idx < i + 1;
    assert m == a[idx];
    i := i + 1;
  }

  assert 0 <= idx < a.Length;
  assert m == a[idx];
  assert forall j :: 0 <= j < a.Length ==> a[j] <= m;
}
