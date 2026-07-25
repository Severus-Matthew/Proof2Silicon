method Min(a: array<int>) returns (m: int)
  requires a != null && a.Length > 0
  ensures exists j: int :: 0 <= j < a.Length && a[j] == m
  ensures forall j: int :: 0 <= j < a.Length ==> m <= a[j]
{
  var i := 0;
  m := a[0];
  while i < a.Length - 1
    invariant 0 <= i < a.Length
    invariant forall j: int :: 0 <= j <= i ==> m <= a[j]
    invariant exists j: int :: 0 <= j <= i && a[j] == m
    decreases a.Length - 1 - i
  {
    var next := a[i + 1];
    if next < m {
      m := next;
    }
    assert m <= a[i + 1];
    i := i + 1;
  }
}
