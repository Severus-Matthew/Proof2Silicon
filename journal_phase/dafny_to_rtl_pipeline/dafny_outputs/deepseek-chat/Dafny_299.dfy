module ElementWiseSubtraction {

  // Function specification: subtracts corresponding elements of two sequences
  // Requires: sequences have equal length
  // Ensures: result length equals input length
  function SubtractSequences(a: seq<int>, b: seq<int>): seq<int>
    requires |a| == |b|
    ensures |SubtractSequences(a, b)| == |a|
  {
    seq(|a|, i requires 0 <= i < |a| => a[i] - b[i])
  }

  // Method to perform element-wise subtraction on arrays
  method ElementWiseSubtract(a: array<int>, b: array<int>) returns (result: array<int>)
    requires a.Length == b.Length
    requires a.Length > 0
    modifies {}
    ensures result.Length == a.Length
    ensures forall i :: 0 <= i < result.Length ==> result[i] == a[i] - b[i]
  {
    result := new int[a.Length];
    var i := 0;
    while i < a.Length
      invariant 0 <= i <= a.Length
      invariant forall j :: 0 <= j < i ==> result[j] == a[j] - b[j]
      invariant result.Length == a.Length
    {
      result[i] := a[i] - b[i];
      i := i + 1;
    }
  }
}
