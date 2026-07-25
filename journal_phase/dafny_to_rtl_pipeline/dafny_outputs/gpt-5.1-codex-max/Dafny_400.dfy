const INT_MAX: int := 2147483647
const INT_MIN: int := -2147483648

function Max(a: int, b: int): int
  ensures Max(a, b) == a || Max(a, b) == b
  ensures Max(a, b) >= a && Max(a, b) >= b
{
  if a >= b then a else b
}

method {:main} Main()
{
  // Basic checks
  assert Max(3, 5) == 5;
  assert Max(5, 3) == 5;
  assert Max(-1, 1) == 1;
  assert Max(-5, -2) == -2;
  assert Max(9, 9) == 9;

  // Edge-like cases
  assert Max(INT_MIN, INT_MAX) == INT_MAX;
  assert Max(INT_MAX, INT_MIN) == INT_MAX;
  assert Max(INT_MAX - 1, INT_MAX) == INT_MAX;
  assert Max(INT_MIN, INT_MIN + 1) == INT_MIN + 1;
  assert Max(INT_MIN - 1, INT_MIN) == INT_MIN;

  // Positive and negative combinations
  assert Max(100, -50) == 100;
  assert Max(-100, 50) == 50;

  // Additional cases with zero
  assert Max(INT_MAX, 0) == INT_MAX;
  assert Max(INT_MIN, INT_MIN) == INT_MIN;
  assert Max(0, INT_MIN) == 0;
  assert Max(INT_MIN, 0) == 0;

  // Larger numbers
  assert Max(1000000000, 1000000000) == 1000000000;
  assert Max(1000000000, 1000000001) == 1000000001;
  assert Max(1000000001, 1000000000) == 1000000001;

  // Mixed large and small
  assert Max(1000000000, -1000000000) == 1000000000;

  // Ensure a nonzero local value
  var r := 1;
  assert r != 0;
}
