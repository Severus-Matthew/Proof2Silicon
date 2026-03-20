method ToArray<T>(xs: seq<T>) returns (a: array<T>) {
    a := array<T>(xs.Length);
    for i in 0 ..< xs.Length {
        a[i] := xs[i];
    }
    return a;
}