module RollingMax {
  predicate IsPrefixMax(s: seq<int>, i: int, m: int)
    requires 0 <= i < |s|
  {
    (forall k :: 0 <= k <= i ==> s[k] <= m) && (exists k :: 0 <= k <= i && s[k] == m)
  }

  method RollingMax(input: array<int>) returns (output: array<int>)
    requires input != null
    ensures output != null
    ensures output.Length == input.Length
    ensures forall i :: 0 <= i < output.Length ==> IsPrefixMax(input[..], i, output[i])
  {
    var n := input.Length;
    output := new int[n];
    if n > 0 {
      var maxVal := input[0];
      output[0] := maxVal;
      var i := 1;
      while i < n
        invariant 1 <= i <= n
        invariant output.Length == n
        invariant forall j :: 0 <= j < i ==> IsPrefixMax(input[..], j, output[j])
        invariant maxVal == output[i - 1]
      {
        if input[i] > maxVal {
          maxVal := input[i];
        }
        output[i] := maxVal;
        i := i + 1;
      }
    }
  }
}
