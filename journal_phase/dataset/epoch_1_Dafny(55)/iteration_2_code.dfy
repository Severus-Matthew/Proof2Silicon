lemma ArraySizePredicate(a: array<int>, xs: seq<int>)
  requires a.Length == |xs|
  ensures a.Length == |xs|
{
  // Trivial since it's in the precondition
}

lemma ArrayLengthPredicate(a: array<int>, n: int)
  requires 0 <= n < a.Length
  ensures a[n] == a[n]  // Example property
{
  // Implementation depends on what you want to prove
}

lemma SequenceArrayEquality(xs: seq<int>, a: array<int>)
  requires a.Length == |xs|
  requires forall i :: 0 <= i < |xs| ==> a[i] == xs[i]
  ensures forall i :: 0 <= i < a.Length ==> a[i] == xs[i]
{
  // The conclusion follows directly from the preconditions
}