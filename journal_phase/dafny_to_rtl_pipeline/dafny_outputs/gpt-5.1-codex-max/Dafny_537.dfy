module f {

  // A simple maximum function over integers
  function max(x: int, y: int): int
    ensures max(x, y) >= x
    ensures max(x, y) >= y
    ensures max(x, y) == x || max(x, y) == y
  {
    if x >= y then x else y
  }

  // Demonstrates properties involving a variable `a`
  method Example(a: int, b: int, c: int) returns (x: int)
    ensures a <= x
    ensures a <= max(a, max(b, c))
    ensures a <= max(max(a, b), c)
  {
    // Choose x large enough to satisfy the postconditions
    x := max(a, max(b, c));

    // Assertions to guide the verifier
    assert max(a, b) >= a;
    assert max(max(a, b), c) >= max(a, b);

    // By the definition of max, these are true
    assert a <= max(max(a, b), c);
    assert a <= max(a, max(b, c));
  }
}
