method FindEvenNumbers(a: array<int>) returns (evens: seq<int>)
    ensures forall i :: 0 <= i < |evens| ==> evens[i] % 2 == 0
    ensures forall j :: 0 <= j < a.Length && a[j] % 2 == 0 ==> a[j] in evens
{
    var result: seq<int> := [];
    var i: int := 0;
    while i < a.Length
        invariant 0 <= i <= a.Length
        invariant forall k :: 0 <= k < |result| ==> result[k] % 2 == 0
        invariant forall j :: 0 <= j < i && a[j] % 2 == 0 ==> a[j] in result
        decreases a.Length - i
    {
        if a[i] % 2 == 0 {
            result := result + [a[i]];
        }
        i := i + 1;
    }
    return result;
}
