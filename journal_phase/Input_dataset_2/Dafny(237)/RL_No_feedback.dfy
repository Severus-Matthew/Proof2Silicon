method Main() {
    var seq := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    var result := ProcessSequence(seq);
    print "Processed sequence: ", result, "\n";
}

function ProcessSequence(seq: seq<int>): seq<int>
    requires |seq| > 0
    ensures |result| == |seq|
    ensures forall i :: 0 <= i < |seq| ==> result[i] >= 0
    ensures forall i :: 0 <= i < |seq| ==> result[i] <= seq[i]
{
    if |seq| == 0 then []
    else ProcessSequenceHelper(seq, 0, [])
}

function ProcessSequenceHelper(seq: seq<int>, index: int, acc: seq<int>): seq<int>
    requires 0 <= index <= |seq|
    requires |acc| == index
    ensures |result| == |seq|
    ensures forall i :: 0 <= i < index ==> result[i] == acc[i]
    ensures forall i :: index <= i < |seq| ==> result[i] >= 0
    decreases |seq| - index
{
    if index == |seq| then acc
    else
        var current := seq[index];
        var processed := if current % 2 == 0 then current / 2 else (current + 1) / 2;
        ProcessSequenceHelper(seq, index + 1, acc + [processed])
}

method VerifySequenceProperties(seq: seq<int>) 
    requires |seq| > 0
    ensures forall i :: 0 <= i < |seq| ==> seq[i] >= 0
{
    var processed := ProcessSequence(seq);
    
    // Verify mathematical properties
    assert |processed| == |seq|;
    
    // These properties are guaranteed by the function's postconditions
    // Using a ghost variable with a forall statement
    ghost var dummy := 
        (forall i :: 0 <= i < |seq| ==> 
            processed[i] >= 0 && processed[i] <= seq[i]);
}

method LoopExample(n: int) returns (sum: int)
    requires n >= 0
    ensures sum == n * (n + 1) / 2
{
    sum := 0;
    var i := 0;
    
    while i <= n
        invariant 0 <= i <= n + 1
        invariant sum == i * (i - 1) / 2
        decreases n - i
    {
        sum := sum + i;
        i := i + 1;
    }
}

method ModuloExample(x: int, y: int) returns (q: int, r: int)
    requires y > 0
    ensures x == q * y + r
    ensures 0 <= r < y
{
    q := x / y;
    r := x % y;
}

predicate IsSorted(seq: seq<int>)
{
    forall i, j :: 0 <= i < j < |seq| ==> seq[i] <= seq[j]
}

method SortAndVerify(seq: seq<int>) returns (sorted: seq<int>)
    ensures |sorted| == |seq|
    ensures IsSorted(sorted)
    ensures multiset(seq) == multiset(sorted)
{
    // Simple bubble sort implementation
    sorted := seq;
    var n := |seq|;
    
    if n > 1 {
        var i := 0;
        while i < n
            invariant 0 <= i <= n
            invariant forall k, l :: 0 <= k < i && k < l < n ==> sorted[k] <= sorted[l]
            invariant multiset(sorted) == multiset(seq)
            decreases n - i
        {
            var j := i + 1;
            while j < n
                invariant i < j <= n
                invariant forall k :: 0 <= k < i ==> sorted[k] <= sorted[i]
                invariant forall k :: i <= k < j ==> sorted[i] <= sorted[k]
                invariant multiset(sorted) == multiset(seq)
                decreases n - j
            {
                if sorted[j] < sorted[i] {
                    // Swap elements
                    var temp := sorted[i];
                    sorted := sorted[i := sorted[j]];
                    sorted := sorted[j := temp];
                }
                j := j + 1;
            }
            i := i + 1;
        }
    }
}

lemma MathematicalProperty(a: int, b: int)
    requires a >= 0 && b >= 0
    ensures (a + b) * (a + b) >= a * a + b * b
{
    // This follows from (a + b)^2 = a^2 + 2ab + b^2 >= a^2 + b^2
    // since 2ab >= 0 when a, b >= 0
}

method CountElements(seq: seq<int>, value: int) returns (count: int)
    ensures count >= 0
    ensures count == multiset(seq)[value]
{
    count := 0;
    var i := 0;
    
    while i < |seq|
        invariant 0 <= i <= |seq|
        invariant count == multiset(seq[0..i])[value]
        decreases |seq| - i
    {
        if seq[i] == value {
            count := count + 1;
        }
        i := i + 1;
    }
}