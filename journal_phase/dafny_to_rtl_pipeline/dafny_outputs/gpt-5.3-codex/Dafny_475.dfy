module Fat {

  function Fat(n: nat): nat
    decreases n
  {
    if n == 0 then 1 else n * Fat(n - 1)
  }

  method Fatorial(n: nat) returns (r: nat)
    ensures r == Fat(n)
  {
    var i: nat := 0;
    r := 1;

    while i < n
      invariant 0 <= i <= n
      invariant r == Fat(i)
      decreases n - i
    {
      i := i + 1;
      r := r * i;
    }

    assert i == n;
    assert r == Fat(n);
  }

}
