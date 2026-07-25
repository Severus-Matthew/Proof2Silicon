method FindMax(a: array<int>) returns (maxVal: int, maxIdx: int)
  requires a != null
  requires a.Length > 0
  ensures 0 <= maxIdx < a.Length
  ensures maxVal == a[maxIdx]
  ensures forall i :: 0 <= i < a.Length ==> a[i] <= maxVal
{
  var i := 1;
  maxIdx := 0;
  maxVal := a[0];

  while i < a.Length
    invariant 1 <= i <= a.Length
    invariant 0 <= maxIdx < i
    invariant maxVal == a[maxIdx]
    invariant forall k :: 0 <= k < i ==> a[k] <= maxVal
    decreases a.Length - i
  {
    if a[i] > maxVal {
      maxVal := a[i];
      maxIdx := i;
      assert maxVal == a[maxIdx];
    }
    i := i + 1;
  }

  assert forall k :: 0 <= k < a.Length ==> a[k] <= maxVal;
}
