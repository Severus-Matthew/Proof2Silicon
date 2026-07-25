method AnyValueExists(seq1: seq<int>, seq2: seq<int>) returns (existsCommon: bool)
  ensures existsCommon == (exists x :: x in seq1 && x in seq2)
{
  var i := 0;
  existsCommon := false;

  while i < |seq1|
    invariant 0 <= i <= |seq1|
    invariant !existsCommon ==> (forall j :: 0 <= j < i ==> seq1[j] !in seq2)
    invariant existsCommon ==> (exists j :: 0 <= j < i && seq1[j] in seq2)
    decreases |seq1| - i
  {
    if seq1[i] in seq2 {
      existsCommon := true;
      // keep scanning so termination is evident and invariants remain easy to maintain
    }
    i := i + 1;
  }

  if existsCommon {
    assert exists x :: x in seq1 && x in seq2;
  } else {
    assert forall j :: 0 <= j < |seq1| ==> seq1[j] !in seq2;
    assert !(exists x :: x in seq1 && x in seq2);
  }
}
