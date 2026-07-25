module Triple {
  // This method takes an integer 'x' as input
  // and returns an integer 'r' that is three times 'x'.
  method TripleNumber(x: int) returns (r: int)
    // Postcondition: the result 'r' is exactly 3 times the input 'x'
    ensures r == 3 * x
  {
    // Compute the triple of x
    r := 3 * x;
  }
}
