module F {
  method MaxArray(a: array<int>) returns (maxVal: int)
    requires a != null
    requires a.Length > 0
    ensures forall i: int :: 0 <= i < a.Length ==> a[i] <= maxVal
    ensures exists i: int :: 0 <= i < a.Length && a[i] == maxVal
  {
    maxVal := a[0];
    var i: int := 1;
    while i < a.Length
      invariant 1 <= i <= a.Length
      invariant forall j: int :: 0 <= j < i ==> a[j] <= maxVal
      invariant exists j: int :: 0 <= j < i && a[j] == maxVal
      decreases a.Length - i
    {
      if a[i] > maxVal {
        maxVal := a[i];
      }
      i := i + 1;
    }
  }
}
