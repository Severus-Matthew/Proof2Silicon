method SumOfSquaresOfFirstNOddNumbers(n: int) returns (sum: int)
  requires n >= 0
  ensures sum == n * (2 * n - 1) * (2 * n + 1) / 3
{
  var i := 0;
  sum := 0;

  while i < n
    invariant 0 <= i <= n
    invariant sum == i * (2 * i - 1) * (2 * i + 1) / 3
    decreases n - i
  {
    var odd := 2 * i + 1;
    sum := sum + odd * odd;
    i := i + 1;
  }

  assert i == n;
}
