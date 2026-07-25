method UseConstructToDescribePurpose(input: seq<int>) returns (output: seq<int>)
    requires |input| > 0
    ensures |output| == |input|
    ensures forall i :: 0 <= i < |input| ==> output[i] == input[|input| - 1 - i]
{
    output := [];
    var i := 0;
    while i < |input|
        invariant 0 <= i <= |input|
        invariant |output| == i
        invariant forall j :: 0 <= j < i ==> output[j] == input[|input| - 1 - j]
        decreases |input| - i
    {
        output := output + [input[|input| - 1 - i]];
        i := i + 1;
    }
}
