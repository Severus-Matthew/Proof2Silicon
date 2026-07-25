module ElementWiseSubtraction {

  method ElementWiseSubtract(a: array<int>, b: array<int>) returns (c: array<int>)
    requires a != null && b != null
    requires a.Length == b.Length
    ensures c != null
    ensures c.Length == a.Length
    ensures forall i :: 0 <= i < a.Length ==> c[i] == a[i] - b[i]
  {
    c := new int[a.Length];
    var i := 0;
    while i < a.Length
      invariant 0 <= i <= a.Length
      invariant c != null && c.Length == a.Length
      invariant forall j :: 0 <= j < i ==> c[j] == a[j] - b[j]
      decreases a.Length - i
    {
      c[i] := a[i] - b[i];
      i := i + 1;
    }
  }

}
