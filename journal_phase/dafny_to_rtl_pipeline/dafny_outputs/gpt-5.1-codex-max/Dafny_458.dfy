module FindMax {
  predicate isMaxIndex(a: array<int>, idx: int)
    reads a
  {
    0 <= idx < a.Length &&
    forall j :: 0 <= j < a.Length ==> a[idx] >= a[j]
  }

  method FindMax(a: array<int>) returns (max_index: int)
    requires a.Length > 0
    ensures isMaxIndex(a, max_index)
  {
    var i: int := 1;
    max_index := 0;
    var max_value: int := a[0];

    while i < a.Length
      invariant 1 <= i <= a.Length
      invariant 0 <= max_index < a.Length
      invariant max_value == a[max_index]
      invariant forall j :: 0 <= j < i ==> max_value >= a[j]
      decreases a.Length - i
    {
      if a[i] > max_value {
        max_index := i;
        max_value := a[i];
      }
      i := i + 1;
    }
  }
}
