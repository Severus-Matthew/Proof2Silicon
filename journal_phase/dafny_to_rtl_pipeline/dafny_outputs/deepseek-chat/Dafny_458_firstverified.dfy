module FindMax {
  // Returns the maximum element in the array.
  // Requires: a is non-empty.
  // Ensures: result is an element of a and is >= every element of a.
  method FindMax(a: array<int>) returns (max: int)
    requires a.Length > 0
    ensures forall i :: 0 <= i < a.Length ==> max >= a[i]
    ensures exists i :: 0 <= i < a.Length && max == a[i]
  {
    max := a[0];
    var i := 1;
    while i < a.Length
      invariant 1 <= i <= a.Length
      invariant forall j :: 0 <= j < i ==> max >= a[j]
      invariant exists j :: 0 <= j < i && max == a[j]
      decreases a.Length - i
    {
      if a[i] > max {
        max := a[i];
      }
      i := i + 1;
    }
  }
}
