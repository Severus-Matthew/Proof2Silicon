function SumOfSquaresOfFirstNOddNumbersFormula(n: int): int
    requires n >= 0
{
    n * (2 * n - 1) * (2 * n + 1) / 3
}

method SumOfSquaresOfFirstNOddNumbers(n: int) returns (sum: int)
    requires n >= 0
    ensures sum == SumOfSquaresOfFirstNOddNumbersFormula(n)
{
    sum := 0;
    var i := 0;
    var odd := 1;
    while i < n
        invariant 0 <= i <= n
        invariant odd == 2 * i + 1
        invariant sum == SumOfSquaresOfFirstNOddNumbersFormula(i)
        decreases n - i
    {
        sum := sum + odd * odd;
        odd := odd + 2;
        i := i + 1;
    }
}
