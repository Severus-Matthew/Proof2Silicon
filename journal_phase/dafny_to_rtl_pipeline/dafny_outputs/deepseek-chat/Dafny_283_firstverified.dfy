method FindMax(arr: array<int>) returns (max: int)
    requires arr.Length > 0
    ensures forall i :: 0 <= i < arr.Length ==> arr[i] <= max
    ensures exists i :: 0 <= i < arr.Length && arr[i] == max
{
    max := arr[0];
    var i := 1;
    while i < arr.Length
        invariant 1 <= i <= arr.Length
        invariant forall j :: 0 <= j < i ==> arr[j] <= max
        invariant exists j :: 0 <= j < i && arr[j] == max
    {
        if arr[i] > max {
            max := arr[i];
        }
        i := i + 1;
    }
}

method Main() {
    var a := new int[5] [3, 7, 2, 9, 5];
    var m := FindMax(a);
    print "Maximum element is: ", m, "\n";
}
