class SumOfCubes {

  /// Triangular number function T(x) = x*(x+1)/2
  static function Tri(x: int): int {
    x * (x + 1) / 2
  }

  /// Closed-form sum of cubes from n to m, inclusive
  static function SumCubesClosed(n: int, m: int): int
    requires n <= m
  {
    Tri(m) * Tri(m) - Tri(n - 1) * Tri(n - 1)
  }

  /// Helper lemma: if both arguments are even, then the sum of their halves
  /// equals half of their sum.
  static lemma EvenHalves(x: int, y: int)
    requires x % 2 == 0 && y % 2 == 0
    ensures x / 2 + y / 2 == (x + y) / 2
  {
    assert x == 2 * (x / 2);
    assert y == 2 * (y / 2);
    assert x + y == 2 * ((x / 2) + (y / 2));
    assert (x + y) == 2 * ((x + y) / 2);
    calc {
      (x + y) / 2;
      == (2 * ((x / 2) + (y / 2))) / 2;
      == (x / 2) + (y / 2);
    }
  }

  /// Helper lemma: if both arguments are odd, then adding 1 to the sum of their halves
  /// equals half of their sum.
  static lemma OddHalves(x: int, y: int)
    requires x % 2 == 1 && y % 2 == 1
    ensures x / 2 + y / 2 + 1 == (x + y) / 2
  {
    assert x == 2 * (x / 2) + 1;
    assert y == 2 * (y / 2) + 1;
    calc {
      (x + y) / 2;
      == (2 * (x / 2) + 1 + 2 * (y / 2) + 1) / 2;
      == (2 * (x / 2 + y / 2 + 1)) / 2;
      == x / 2 + y / 2 + 1;
    }
  }

  /// If one factor is even, the product is even.
  static lemma EvenMul(a: int, b: int)
    requires a % 2 == 0
    ensures (a * b) % 2 == 0
  {
    assert a == 2 * (a / 2);
    calc {
      (a * b) % 2;
      == (2 * (a / 2) * b) % 2;
      == (2 * ((a / 2) * b)) % 2;
      == 0;
    }
  }

  /// Both i*(i+1) and (i-1)*i are even.
  static lemma ConsecutiveProductsEven(i: int)
    ensures (i * (i + 1)) % 2 == 0 && ((i - 1) * i) % 2 == 0
  {
    if i % 2 == 0 {
      EvenMul(i, i + 1);
      EvenMul(i, i - 1);
    } else {
      assert i == 2 * (i / 2) + 1;
      assert i + 1 == 2 * ((i / 2) + 1);
      assert i - 1 == 2 * (i / 2);
      assert (i + 1) % 2 == 0;
      assert (i - 1) % 2 == 0;
      EvenMul(i + 1, i);
      EvenMul(i - 1, i);
    }
  }

  /// Lemma to relate consecutive triangular numbers to a cube
  static lemma CubeIdentity(i: int)
    ensures Tri(i) * Tri(i) - Tri(i - 1) * Tri(i - 1) == i * i * i
  {
    // Tri(i) - Tri(i-1) = i
    assert Tri(i) - Tri(i - 1) == i by {
      calc {
        Tri(i) - Tri(i - 1);
        == i * (i + 1) / 2 - (i - 1) * i / 2;
        == (i * (i + 1) - (i - 1) * i) / 2;
        == 2 * i / 2;
        == i;
      }
    }
    // Ensure the numerators are even before combining the halves
    ConsecutiveProductsEven(i);
    // Tri(i) + Tri(i-1) = i*i
    assert Tri(i) + Tri(i - 1) == i * i by {
      calc {
        Tri(i) + Tri(i - 1);
        == i * (i + 1) / 2 + (i - 1) * i / 2;
        == { EvenHalves(i * (i + 1), (i - 1) * i); }
           (i * (i + 1) + (i - 1) * i) / 2;
        == (i * ((i + 1) + (i - 1))) / 2;
        == (i * (2 * i)) / 2;
        == i * i;
      }
    }
    // Difference of squares identity to get the cube
    calc {
      Tri(i) * Tri(i) - Tri(i - 1) * Tri(i - 1);
      == (Tri(i) - Tri(i - 1)) * (Tri(i) + Tri(i - 1));
      == i * (i * i);
      == i * i * i;
    }
  }

  /// Iterative computation of the sum of cubes from n to m inclusive.
  static method sumOfCubes(n: int, m: int) returns (res: int)
    requires n <= m
    ensures res == SumCubesClosed(n, m)
  {
    var i := n;
    var sum := 0;

    while i <= m
      invariant n <= i <= m + 1
      invariant sum == Tri(i - 1) * Tri(i - 1) - Tri(n - 1) * Tri(n - 1)
      decreases m - i + 1
    {
      CubeIdentity(i);
      sum := sum + i * i * i;
      i := i + 1;
    }
    res := sum;
  }

  /// Direct computation using the closed-form combinatorial formula.
  static method sumOfCubesFormula(n: int, m: int) returns (res: int)
    requires n <= m
    ensures res == SumCubesClosed(n, m)
  {
    res := SumCubesClosed(n, m);
  }

  /// Method to check relationships between different summations and the combinatorial formula.
  static method verifyProperties()
  {
    // Check for n = 1..k: sum of cubes equals square of triangular number
    var n := 1;
    var k := 10;
    var iterative := sumOfCubes(n, k);
    var closed := sumOfCubesFormula(n, k);
    assert iterative == Tri(k) * Tri(k);
    assert iterative == closed;

    // Check for an arbitrary range
    var a := 3;
    var b := 7;
    var iterative2 := sumOfCubes(a, b);
    var closed2 := sumOfCubesFormula(a, b);
    assert iterative2 == closed2;

    // Range splitting property: [a..b] = [a..c] + [c+1..b]
    var c := 5;
    if a <= c && c < b {
      var left := sumOfCubes(a, c);
      var right := sumOfCubes(c + 1, b);
      assert iterative2 == left + right;
    }
  }
}
