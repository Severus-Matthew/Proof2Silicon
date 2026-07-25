predicate Divides(d: nat, n: nat)
{
  if d == 0 then n == 0 else n % d == 0
}

// Mathematical specification of the GCD using Euclid's algorithm
function GCD(a: nat, b: nat): nat
  decreases b
{
  if b == 0 then a else GCD(b, a % b)
}

// Iterative computation of the GCD
method ComputeGcd(a0: nat, b0: nat) returns (g: nat)
  requires a0 > 0 || b0 > 0
  ensures g == GCD(a0, b0)
{
  var x := a0;
  var y := b0;

  // Euclidean algorithm
  while y != 0
    invariant x >= 0 && y >= 0
    invariant GCD(x, y) == GCD(a0, b0)
    decreases y
  {
    var r := x % y;
    // r is strictly less than y when y > 0
    assert r < y;
    x := y;
    y := r;
  }

  g := x;
  // At loop exit, y == 0, so by the definition of GCD we have g == GCD(a0, b0)
  assert g == GCD(a0, b0);
}

// Return the minimum second element among all sequences in the array
method MinSecondValueFirst(a: array<seq<int>>) returns (min: int)
  requires a != null && a.Length > 0
  requires forall i: nat :: i < a.Length ==> |a[i]| >= 2
  ensures forall i: nat :: i < a.Length ==> min <= a[i][1]
  ensures exists i: nat :: i < a.Length && min == a[i][1]
{
  var i: nat := 1;
  min := a[0][1];

  while i < a.Length
    invariant 1 <= i <= a.Length
    invariant forall j: nat :: j < i ==> min <= a[j][1]
    invariant exists k: nat :: k < i && min == a[k][1]
    decreases a.Length - i
  {
    if a[i][1] < min {
      min := a[i][1];
    }
    i := i + 1;
  }
}

// Simple test harness
method Main()
{
  var x: nat := 48;
  var y: nat := 18;
  var g := ComputeGcd(x, y);
  assert g == 6;

  var g2 := ComputeGcd(7, 13);
  assert g2 == 1;

  var g3 := ComputeGcd(0, 25);
  assert g3 == 25;

  // Example usage of MinSecondValueFirst
  var arr := new seq<int>[2];
  arr[0] := [5, 3, 7];
  arr[1] := [1, -2, 4];
  var m := MinSecondValueFirst(arr);
  assert m == -2;
}
