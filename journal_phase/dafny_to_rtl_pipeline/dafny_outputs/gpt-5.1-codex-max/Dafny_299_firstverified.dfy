module ElementWiseSubtraction {
  method ElementWiseSubtract(a: array<int>, b: array<int>) returns (result: array<int>)
    requires a != null && b != null && a.Length == b.Length
    ensures result != null && result.Length == a.Length
    ensures forall i :: 0 <= i < a.Length ==> result[i] == a[i] - b[i]
  {
    var n := a.Length;
    result := new int[n];
    var i := 0;
    while i < n
      invariant 0 <= i <= n
      invariant forall k :: 0 <= k < i ==> result[k] == a[k] - b[k]
    {
      result[i] := a[i] - b[i];
      i := i + 1;
    }
  }
}
