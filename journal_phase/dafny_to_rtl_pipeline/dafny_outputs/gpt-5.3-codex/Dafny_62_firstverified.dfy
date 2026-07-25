method Triple(x: int) returns (r: int)
    ensures r == 3 * x
{
    // Use the following Dafny constructs to achieve the desired functionality:
    // method, ensures, assignment statements, and assertions.

    // Step 1: Initialize the return value r to 0.
    r := 0;
    assert r == 0;

    // Step 2: Add x to r (first addition).
    r := r + x;
    assert r == x;

    // Step 3: Add x to r again (second addition).
    r := r + x;
    assert r == 2 * x;

    // Step 4: Add x to r one more time (third addition).
    r := r + x;
    assert r == 3 * x;
}
