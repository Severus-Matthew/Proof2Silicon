method calculateLCM(m: int, n: int) returns (lcm: int)
  requires 1 <= m && 1 <= n
  ensures lcm == m * n / gcd(m, n)
{
  // Calculate LCM using the formula: LCM(a,b) = a*b / GCD(a,b)
  var g := gcd(m, n);
  lcm := m * n / g;
}

method gcd(a: int, b: int) returns (g: int)
  requires 1 <= a && 1 <= b
  ensures g > 0
  ensures a % g == 0 && b % g == 0
{
  // Euclidean algorithm for GCD
  var x := a;
  var y := b;
  while (y != 0)
    invariant x > 0 && y >= 0
    invariant gcd(x, y) == gcd(a, b)
  {
    var t := y;
    y := x % y;
    x := t;
  }
  g := x;
}