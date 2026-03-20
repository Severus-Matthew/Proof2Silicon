method ToArray<T>(xs: seq<T>) returns (a: array<T>) {
    a := array<T>(xs.Count);
    for i in 0 ..< xs.Count {
        a[i] := xs[i];
    }
    return a;
}