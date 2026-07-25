module MultiplyElements {
  // This method multiplies corresponding elements of two integer sequences.
  // It assumes both input sequences have the same length and returns a new
  // sequence where each element is the product of the inputs at that index.
  method MultiplyElements(a: seq<int>, b: seq<int>) returns (result: seq<int>)
    requires |a| == |b|
    ensures |result| == |a|
    ensures forall i:int :: 0 <= i < |a| ==> result[i] == a[i] * b[i]
  {
    var len := |a|;
    var tmp := new int[len];
    var i := 0;
    while i < len
      invariant 0 <= i <= len
      invariant tmp.Length == len
      invariant forall j:int :: 0 <= j < i ==> tmp[j] == a[j] * b[j]
      decreases len - i
    {
      tmp[i] := a[i] * b[i];
      i := i + 1;
    }
    result := tmp[..];
    assert |result| == |a|;
    assert forall i:int :: 0 <= i < |a| ==> result[i] == a[i] * b[i];
  }
}
