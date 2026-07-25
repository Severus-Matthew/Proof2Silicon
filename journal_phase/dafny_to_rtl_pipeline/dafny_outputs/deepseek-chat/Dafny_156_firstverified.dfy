// A Dafny program that computes the sum of an array of integers.
// It includes preconditions, postconditions, loop invariants, and termination guarantees.

method ArraySum(arr: array<int>) returns (sum: int)
    // The method takes an array of integers and returns the sum of its elements.
    requires arr != null
    // The array must not be null.
    ensures sum == SumOfArray(arr)
    // The result equals the sum of all elements in the array.
{
    sum := 0;
    var i: int := 0;

    // Loop through the array and accumulate the sum.
    while i < arr.Length
        invariant 0 <= i <= arr.Length
        // i is within the bounds of the array.
        invariant sum == SumOfArrayUpTo(arr, i)
        // sum equals the sum of elements from index 0 to i-1.
        decreases arr.Length - i
        // The loop terminates because the difference decreases each iteration.
    {
        sum := sum + arr[i];
        i := i + 1;
    }
}

// Helper function to compute the sum of all elements in an array.
function SumOfArray(arr: array<int>): int
    requires arr != null
    reads arr
{
    if arr.Length == 0 then 0 else SumOfArrayUpTo(arr, arr.Length)
}

// Helper function to compute the sum of elements from index 0 to k-1.
function SumOfArrayUpTo(arr: array<int>, k: int): int
    requires arr != null
    requires 0 <= k <= arr.Length
    reads arr
{
    if k == 0 then 0 else SumOfArrayUpTo(arr, k-1) + arr[k-1]
}
