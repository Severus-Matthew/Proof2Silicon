module AbsMax {
    // Returns the absolute value of x
    method Abs(x: int) returns (y: int)
        ensures y >= 0
        ensures y == x || y == -x
    {
        if x < 0 {
            y := -x;
        } else {
            y := x;
        }
    }

    // Returns the maximum of a and b
    method Max(a: int, b: int) returns (c: int)
        ensures c >= a && c >= b
        ensures c == a || c == b
    {
        if a >= b {
            c := a;
        } else {
            c := b;
        }
    }
}
