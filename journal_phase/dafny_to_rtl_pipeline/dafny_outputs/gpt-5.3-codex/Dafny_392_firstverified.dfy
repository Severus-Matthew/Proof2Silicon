method MaxOfArray(a: array<int>) returns (m: int)
  requires a != null
  requires a.Length > 0
  ensures forall i :: 0 <= i < a.Length ==> a[i] <= m
  ensures exists i :: 0 <= i < a.Length && a[i] == m
{
  var i := 1;
  m := a[0];

  while i < a.Length
    invariant 1 <= i <= a.Length
    invariant forall j :: 0 <= j < i ==> a[j] <= m
    invariant exists j :: 0 <= j < i && a[j] == m
    decreases a.Length - i
  {
    if a[i] > m {
      m := a[i];
    }
    i := i + 1;
  }
}
