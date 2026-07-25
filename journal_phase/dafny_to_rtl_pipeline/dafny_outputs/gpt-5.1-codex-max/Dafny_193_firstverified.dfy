module Test {

  predicate positive(a: int, b: int)
    reads {}
  {
    a <= b && forall i :: a <= i < b ==> a <= i && a < b
  }

  method mfirstNegative(a: array<int>) returns (idx: int)
    requires a != null
    requires a.Length > 0
    requires a[0] >= 0
    requires forall i :: 1 <= i < a.Length - 1 ==> a[i] >= 0
    requires a[a.Length - 1] < 0
    ensures 0 <= idx < a.Length
    ensures a[idx] < 0
    ensures forall j :: 0 <= j < idx ==> a[j] >= 0
  {
    var i := 0;
    while i < a.Length
      invariant 0 <= i <= a.Length
      invariant forall j :: 0 <= j < i ==> a[j] >= 0
      decreases a.Length - i
    {
      if a[i] < 0 {
        idx := i;
        return;
      }
      i := i + 1;
    }
    // Given the preconditions, the loop must return before termination
    // but we include a default assignment to appease total correctness
    idx := a.Length - 1;
  }
}
