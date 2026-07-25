method Mult(x : nat, y : nat) returns (r : nat)
    ensures r == x * y
{
    r := 0;
    var i : nat := x;
    while i > 0
        invariant r == (x - i) * y
        decreases i
    {
        r := r + y;
        i := i - 1;
    }
}
