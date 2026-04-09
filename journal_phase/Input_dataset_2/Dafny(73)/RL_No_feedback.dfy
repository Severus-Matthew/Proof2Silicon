// Method to compute a^n efficiently using exponentiation by squaring
method Power(a: int, n: int) returns (result: int)
  requires n >= 0
  ensures result == PowerSpec(a, n)  // This is equivalent to result == a^n
{
  result := 1;
  var base := a;
  var exp := n;
  
  while exp > 0
    // Loop invariant: result * (base^exp) == a^n
    invariant result * PowerSpec(base, exp) == PowerSpec(a, n)
    decreases exp
  {
    if exp % 2 == 1 {
      result := result * base;
    }
    base := base * base;
    exp := exp / 2;
  }
}

// Helper function that defines what a^n means mathematically
// This is equivalent to the mathematical notation a^n
function PowerSpec(a: int, n: int): int
  requires n >= 0
  decreases n
{
  if n == 0 then 1
  else a * PowerSpec(a, n - 1)
}

// Test method with various cases
method TestPower() {
  var r1 := Power(2, 0);
  assert r1 == 1;  // Should be a^0 = 1
  
  var r2 := Power(2, 3);
  assert r2 == 2 * 2 * 2;  // Should be a^3 = 2^3
  
  var r3 := Power(3, 2);
  assert r3 == 3 * 3;  // Should be a^2 = 3^2
  
  print "All tests passed!\n";
}

// Additional test method that takes parameters
method ParameterizedTest(a: int, n: int) returns (result: int)
  requires n >= 0
  ensures result == PowerSpec(a, n)
{
  result := Power(a, n);
}