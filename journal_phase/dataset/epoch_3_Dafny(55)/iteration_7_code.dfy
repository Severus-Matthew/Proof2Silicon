method ToArray(xs: seq<int>) returns (a: array<int>)
  requires xs.Distinct()
  ensures a.Length == |xs|
  ensures fresh(a)
  ensures forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
{
  // Allocate fresh array matching sequence length
  a := new int[|xs|];
  
  // Copy elements from sequence to array
  var i := 0;
  while i < |xs|
    invariant 0 <= i <= |xs|
    invariant forall j :: 0 <= j < i ==> a[j] == xs[j]
  {
    a[i] := xs[i];
    i := i + 1;
  }
}

// Example usage:
// var xs: seq<int> := [1, 2, 3, 4, 5];
// var arr: array<int> := ToArray(xs);