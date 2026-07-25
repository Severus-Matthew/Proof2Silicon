// A simple Dafny program that computes the maximum element in an array
// and verifies its correctness.

method FindMax(a: array<int>) returns (max: int)
    // The array must not be empty.
    requires a.Length > 0
    // The result is an element of the array.
    ensures exists i :: 0 <= i < a.Length && max == a[i]
    // The result is greater than or equal to every element.
    ensures forall i :: 0 <= i < a.Length ==> max >= a[i]
{
    // Initialize max to the first element.
    max := a[0];
    var i := 1;

    // Loop invariant: we have examined elements 0..i-1.
    // max is the maximum among those examined.
    while i < a.Length
        invariant 1 <= i <= a.Length
        invariant forall j :: 0 <= j < i ==> max >= a[j]
        invariant exists j :: 0 <= j < i && max == a[j]
    {
        if a[i] > max {
            max := a[i];
        }
        i := i + 1;
    }
}

// Example usage
method Main() {
    var arr := new int[5] [1, 3, 5, 2, 4];
    var m := FindMax(arr);
    print "Maximum element is: ", m, "\n";
}
