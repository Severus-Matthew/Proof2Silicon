method Triple(x: int) returns (r: int)
    ensures r == 3 * x
{
    // Step 1: Initialize the return value r to 0.
    r := 0;

    // Step 2: Add x to r three times to compute 3*x.
    r := r + x;
    r := r + x;
    r := r + x;
}
