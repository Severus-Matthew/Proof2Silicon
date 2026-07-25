module Mod2 {

  method addSome(n: nat) returns (r: nat)
    requires n >= 0
    ensures r > n
    ensures r >= 6
  {
    // A simple non-recursive implementation that always increases n
    // and guarantees the result is at least 6.
    if n < 5 {
      r := 6;
    } else {
      r := n + 1;
    }

    assert r > n;
    assert r >= 6;
  }

  method m(n: nat) returns (res: nat)
    requires n >= 0
    ensures res >= 6
  {
    res := addSome(n);
    assert res >= 6;
  }
}
