module Gen {

  method GenerateSequence(n: nat) returns (s: seq<nat>)
    requires n >= 0
    ensures s == seq(n, i => i)
  {
    var i: nat := 0;
    s := [];
    while i < n
      invariant 0 <= i <= n
      invariant |s| == i
      invariant s == seq(i, j => j)
      decreases n - i
    {
      s := s + [i];
      i := i + 1;
    }
    assert i == n;
    assert s == seq(n, i => i);
  }
}
