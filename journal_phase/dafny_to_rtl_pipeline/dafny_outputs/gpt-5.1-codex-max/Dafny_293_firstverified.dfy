module SumOfSquaresOfFirstNOddNumbers {
  method SumOfFirstNOddNumbers(n: nat) returns (sum: nat)
    requires n >= 0
    ensures sum == n * n
    // This method computes the sum of the first n odd numbers (1, 3, 5, ..., 2*n-1)
    // and proves that this sum equals n^2.
  {
    var i := 0;
    sum := 0;
    while i < n
      invariant 0 <= i <= n
      invariant sum == i * i
      decreases n - i
    {
      // Before iteration: sum == i*i
      // We add the next odd number (2*i + 1) to sum.
      sum := sum + (2 * i + 1);
      i := i + 1;
      // After iteration: sum == (i*i) where i is incremented by 1
    }
    // When the loop exits, i == n and sum == n*n
  }
}
