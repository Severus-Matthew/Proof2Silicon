method FindMax(arr: array<int>) returns (max: int)
    requires arr.Length > 0
    ensures forall i :: 0 <= i < arr.Length ==> max >= arr[i]
    ensures exists i :: 0 <= i < arr.Length && max == arr[i]
{
    max := arr[0];
    var i := 1;
    while i < arr.Length
        invariant 1 <= i <= arr.Length
        invariant forall j :: 0 <= j < i ==> max >= arr[j]
        invariant exists j :: 0 <= j < i && max == arr[j]
        decreases arr.Length - i
    {
        if arr[i] > max {
            max := arr[i];
        }
        i := i + 1;
    }
}
