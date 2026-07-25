method SelectionSort(a: array<int>)
    modifies a
    ensures sorted(a[..])
    ensures multiset(a[..]) == multiset(old(a[..]))
{
    var n := a.Length;
    var i := 0;
    while i < n
        invariant 0 <= i <= n
        invariant forall k, l :: 0 <= k < l < i ==> a[k] <= a[l]
        invariant forall k, l :: 0 <= k < i && i <= l < n ==> a[k] <= a[l]
        invariant multiset(a[..]) == multiset(old(a[..]))
        decreases n - i
    {
        var minIndex := i;
        var j := i + 1;
        while j < n
            invariant i < j <= n
            invariant i <= minIndex < n
            invariant forall k :: i <= k < j ==> a[minIndex] <= a[k]
            invariant forall k, l :: 0 <= k < l < i ==> a[k] <= a[l]
            invariant forall k, l :: 0 <= k < i && i <= l < n ==> a[k] <= a[l]
            invariant multiset(a[..]) == multiset(old(a[..]))
            decreases n - j
        {
            if a[j] < a[minIndex] {
                minIndex := j;
            }
            j := j + 1;
        }
        // swap a[i] and a[minIndex]
        var temp := a[i];
        a[i] := a[minIndex];
        a[minIndex] := temp;
        i := i + 1;
    }
}

predicate sorted(s: seq<int>)
{
    forall i, j :: 0 <= i < j < |s| ==> s[i] <= s[j]
}
