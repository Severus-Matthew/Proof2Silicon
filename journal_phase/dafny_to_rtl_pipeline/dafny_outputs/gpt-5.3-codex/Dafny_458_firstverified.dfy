module FindMax {

  method FindMax(a: array<int>) returns (idx: int, maxVal: int)
    requires a != null
    requires a.Length > 0
    ensures 0 <= idx < a.Length
    ensures maxVal == a[idx]
    ensures forall j :: 0 <= j < a.Length ==> a[j] <= maxVal
  {
    var i := 1;
    idx := 0;
    maxVal := a[0];

    while i < a.Length
      invariant 1 <= i <= a.Length
      invariant 0 <= idx < i
      invariant maxVal == a[idx]
      invariant forall j :: 0 <= j < i ==> a[j] <= maxVal
      decreases a.Length - i
    {
      if a[i] > maxVal {
        idx := i;
        maxVal := a[i];
      }
      i := i + 1;
    }

    assert forall j :: 0 <= j < a.Length ==> a[j] <= maxVal;
  }
}
