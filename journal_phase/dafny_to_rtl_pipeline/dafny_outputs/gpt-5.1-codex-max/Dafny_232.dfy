module GCDProgram {

  function Abs(n: int): int {
    if n < 0 then -n else n
  }

  // Mathematical specification of gcd using Euclid's algorithm (for specs only)
  function gcdSpec(x: int, y: int): int
    requires 0 <= x && 0 <= y
    decreases y
  {
    if y == 0 then x else gcdSpec(y, x % y)
  }

  method ComputeGCD(a: int, b: int) returns (g: int)
    ensures g >= 0
    ensures g == gcdSpec(Abs(a), Abs(b))
  {
    var x := Abs(a);
    var y := Abs(b);
    while y != 0
      invariant x >= 0 && y >= 0
      invariant gcdSpec(x, y) == gcdSpec(Abs(a), Abs(b))
      decreases y
    {
      assert y > 0; // because y != 0 and y >= 0
      var t := y;
      y := x % y;
      x := t;
    }
    g := x;
    assert g >= 0;
  }

  method Add(a: int, b: int) returns (c: int)
    requires 0 <= a && 0 <= b
    ensures c == a + b
    ensures c >= 0
  {
    var x := a;
    var y := b;
    c := x;
    var k := y;
    while k > 0
      invariant k >= 0
      invariant c == x + (y - k)
      decreases k
    {
      c := c + 1;
      k := k - 1;
    }
  }

  method Main() {
    var a := 10;
    var b := 5;
    var g1 := ComputeGCD(a, b);
    print "GCD of ", a, " and ", b, " is ", g1, "\n";

    a := -10;
    b := 5;
    var g2 := ComputeGCD(a, b);
    print "GCD of ", a, " and ", b, " is ", g2, "\n";

    var s := Add(3, 4);
    print "Sum of 3 and 4 is ", s, "\n";
  }
}
