method Solve(n: int) returns (result: int)
    requires n >= 0
    ensures result == n * (n + 1) / 2
{
    var i := 0;
    result := 0;
    while i < n
        invariant 0 <= i <= n
        invariant result == i * (i + 1) / 2
        decreases n - i
    {
        i := i + 1;
        result := result + i;
    }
}
