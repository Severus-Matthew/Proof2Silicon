method AvgArgs(a: int, b: int) returns (avg: int)
  requires avgTypeCheck(a, b)
  ensures avg == (a + b) / 2
{
  avg := (a + b) / 2;
}

function avgTypeCheck(a: int, b: int): bool
{
  // Ensure that a + b is even so that division by 2 is exact
  (a + b) % 2 == 0
}

function avgArgTypeCheck(a: int, b: int): bool
{
  avgTypeCheck(a, b)
}

method MyMethod(a: int, b: int) returns (result: int)
  requires avgArgTypeCheck(a, b)
{
  var avg := AvgArgs(a, b);
  result := avg;
}

// Helper method to demonstrate the chain works
method TestChain() {
  var a := 10;
  var b := 20;
  
  // Check if the precondition for MyMethod is satisfied
  if avgArgTypeCheck(a, b) {
    var result := MyMethod(a, b);
    assert result == 15; // (10 + 20) / 2 = 15
  }
  
  // Also test with different values
  var c := 12;
  var d := 14;
  if avgArgTypeCheck(c, d) {
    var result2 := MyMethod(c, d);
    assert result2 == 13; // (12 + 14) / 2 = 13
  }
  
  // Test with values that don't satisfy the precondition
  var e := 11;
  var f := 12;
  // This should not execute the method call
  if avgArgTypeCheck(e, f) {
    var result3 := MyMethod(e, f);
    // This assertion won't be reached since 11+12=23 is odd
  }
}