module IterativeMath {
  const MAX: nat := 1000

  // Recursive specifications (for proofs only)
  function fibRec(n: nat): nat
    decreases n
  {
    if n <= 1 then n else fibRec(n - 1) + fibRec(n - 2)
  }

  function factRec(n: nat): nat
    decreases n
  {
    if n == 0 then 1 else n * factRec(n - 1)
  }

  function gcdRec(a: nat, b: nat): nat
    decreases b
  {
    if b == 0 then a else gcdRec(b, a % b)
  }

  method FibIter(n: nat) returns (f: nat)
    requires fibRec(n) <= MAX
    ensures f == fibRec(n)
    ensures f <= MAX
  {
    var i: nat := 0;
    var a: nat := 0; // fib(0)
    var b: nat := 1; // fib(1)

    // Invariant: a == fibRec(i) and b == fibRec(i + 1)
    while i < n
      invariant i <= n
      invariant a == fibRec(i)
      invariant b == fibRec(i + 1)
      decreases n - i
    {
      var next: nat := a + b;
      a := b;
      b := next;
      i := i + 1;
    }
    f := a;
  }

  method FactIter(n: nat) returns (f: nat)
    requires factRec(n) <= MAX
    ensures f == factRec(n)
    ensures f <= MAX
  {
    var i: nat := 0;
    f := 1;
    // Invariant: f == factRec(i)
    while i < n
      invariant i <= n
      invariant f == factRec(i)
      decreases n - i
    {
      i := i + 1;
      f := f * i;
    }
  }

  method GcdIter(a: nat, b: nat) returns (g: nat)
    requires a <= MAX && b <= MAX
    ensures g == gcdRec(a, b)
    ensures g <= MAX
  {
    var x: nat := a;
    var y: nat := b;
    // Euclid's algorithm
    while y != 0
      invariant x <= MAX
      invariant y <= MAX
      invariant gcdRec(x, y) == gcdRec(a, b)
      decreases y
    {
      var temp: nat := y;
      // Because y != 0 and y > 0, x % y < y, so the variant decreases
      y := x % y;
      x := temp;
    }
    g := x;
  }

  method Check(n: nat, m: nat, a: nat, b: nat)
    requires fibRec(n) <= MAX
    requires factRec(m) <= MAX
    requires a <= MAX && b <= MAX
  {
    var f := FibIter(n);
    assert f == fibRec(n);

    var fac := FactIter(m);
    assert fac == factRec(m);

    var g := GcdIter(a, b);
    assert g == gcdRec(a, b);
  }
}
