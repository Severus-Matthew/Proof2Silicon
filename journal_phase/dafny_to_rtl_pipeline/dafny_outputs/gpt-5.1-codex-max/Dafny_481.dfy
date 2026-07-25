class Program {

  // Mathematical specification of the greatest common divisor using Euclid's algorithm
  function gcdSpec(x: int, y: int): int
    requires x >= 0 && y >= 0
    decreases y
  {
    if y == 0 then x else gcdSpec(y, x % y)
  }

  // Iterative computation of the GCD
  method GCD(a: int, b: int) returns (g: int)
    requires a >= 0 && b >= 0
    ensures g == gcdSpec(a, b)
    ensures g >= 0
  {
    var x := a;
    var y := b;
    while y != 0
      invariant x >= 0 && y >= 0
      invariant gcdSpec(x, y) == gcdSpec(a, b)
      decreases y
    {
      var temp := x % y;
      x := y;
      y := temp;
    }
    g := x;
  }

  // Specification of the sequence C(n) using a simple recurrence
  function CSpec(n: nat): nat
    decreases n
  {
    if n == 0 then 0 else CSpec(n - 1) + n * (n + 1) * (n + 2) / 6
  }

  // Iterative computation of the sequence C(n)
  method C(n: nat) returns (result: int)
    requires n < 1000000
    ensures result == CSpec(n)
    ensures result >= 0
  {
    var i: nat := 0;
    var acc: int := 0;
    while i < n
      invariant i <= n
      invariant acc == CSpec(i)
      invariant acc >= 0
      decreases n - i
    {
      i := i + 1;
      acc := acc + i * (i + 1) * (i + 2) / 6;
    }
    result := acc;
  }

  // Simple test harness
  method Main()
  {
    var g1 := GCD(48, 18);
    assert g1 == 6;

    var g2 := GCD(0, 0);
    assert g2 == 0;

    var g3 := GCD(7, 0);
    assert g3 == 7;

    var g4 := GCD(0, 9);
    assert g4 == 9;

    var c5 := C(5);
    assert c5 == CSpec(5);
  }
}
