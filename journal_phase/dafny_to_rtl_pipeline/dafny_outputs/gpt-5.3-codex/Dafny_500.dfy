module IterativeMathOps {

  function fibSpec(n: nat): nat
    decreases n
  {
    if n < 2 then n else fibSpec(n - 1) + fibSpec(n - 2)
  }

  function factSpec(n: nat): nat
    decreases n
  {
    if n == 0 then 1 else n * factSpec(n - 1)
  }

  function gcdSpec(a: nat, b: nat): nat
    decreases b
  {
    if b == 0 then a else gcdSpec(b, a % b)
  }

  method fibIter(n: nat) returns (r: nat)
    ensures r == fibSpec(n)
  {
    if n == 0 {
      r := 0;
      return;
    }

    var i: nat := 1;
    var a: nat := 0;
    var b: nat := 1;
    var c: nat := 1;

    while i < n
      invariant 1 <= i <= n
      invariant a == fibSpec(i - 1)
      invariant b == fibSpec(i)
      invariant c == b
      decreases n - i
    {
      c := a + b;
      a := b;
      b := c;
      i := i + 1;
    }

    r := c;
    assert r == fibSpec(n);
  }

  method factIter(n: nat) returns (r: nat)
    ensures r == factSpec(n)
  {
    if n == 0 {
      r := 1;
      return;
    }

    var i: nat := 1;
    var acc: nat := 1;

    while i < n
      invariant 1 <= i <= n
      invariant acc == factSpec(i)
      decreases n - i
    {
      i := i + 1;
      acc := acc * i;
    }

    r := acc;
    assert r == factSpec(n);
  }

  method gcdIter(a: nat, b: nat) returns (g: nat)
    ensures g == gcdSpec(a, b)
  {
    var x: nat := a;
    var y: nat := b;

    while y != 0
      invariant gcdSpec(x, y) == gcdSpec(a, b)
      decreases y
    {
      var t: nat := x % y;
      x := y;
      y := t;
    }

    g := x;
    assert g == gcdSpec(a, b);
  }

  method demoLetInfixMod(m: nat, n: nat) returns (sum: nat, rem: nat)
    requires n > 0
    ensures sum == m + n
    ensures rem == m % n
  {
    var s: nat := m + n;
    sum := s;

    rem := m % n;
    assert 0 <= rem < n;
  }
}
