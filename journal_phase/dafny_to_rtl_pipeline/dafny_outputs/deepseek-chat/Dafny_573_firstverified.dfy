function fib(n: nat): nat
{
    if n == 0 then 0
    else if n == 1 then 1
    else fib(n - 1) + fib(n - 2)
}

method Fib(n: int) returns (result: int)
    requires n >= 0
    ensures result == fib(n)
{
    if n == 0 {
        return 0;
    }
    var a: int := 0;
    var b: int := 1;
    var i: int := 1;
    while i < n
        invariant 1 <= i <= n
        invariant a == fib(i - 1)
        invariant b == fib(i)
        decreases n - i
    {
        var temp: int := b;
        b := a + b;
        a := temp;
        i := i + 1;
    }
    return b;
}
