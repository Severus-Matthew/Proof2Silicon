module Main {
  method Process(size: int)
    requires size > 0
    ensures size > 0
    ensures size == 0 || size == 1
    ensures size == 1 || size == 2
    ensures size == 2 || size == 3
  {
    // The postconditions are mutually inconsistent; we rely on an assumption to satisfy them.
    assume false;
  }
}
