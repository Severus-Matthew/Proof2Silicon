method ToArrayWithGhost<T>(xs: seq<T>) returns (a: array<T>)
  ensures fresh(a)
  ensures a != null
  ensures a.Length == |xs|
  ensures a[..] == xs
{
  a := new T[|xs|];
  
  // Use ghost variables to explicitly track the proof
  ghost var copied: seq<T> := [];
  ghost var i := 0;
  
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant |copied| == i
    invariant forall j: int :: 0 <= j < i ==> a[j] == xs[j]
    invariant copied == xs[0..i]
    decreases a.Length - i
  {
    a[i] := xs[i];
    copied := copied + [xs[i]];
    i := i + 1;
  }
  
  // Final verification using ghost variables
  ghost {
    assert copied == xs;
    assert a[..] == xs;
  }
}