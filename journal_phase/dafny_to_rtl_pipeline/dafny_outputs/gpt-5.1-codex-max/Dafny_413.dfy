module SelectionSort {

  predicate sorted(s: seq<int>)
    reads {}
  {
    forall i, j :: 0 <= i < j < |s| ==> s[i] <= s[j]
  }

  method SelectionSort(arr: array<int>)
    modifies arr
    ensures sorted(arr[..])
    ensures multiset(arr[..]) == multiset(old(arr[..]))
  {
    var i := 0;
    while i < arr.Length
      invariant 0 <= i <= arr.Length
      invariant sorted(arr[..i])
      invariant forall k, j :: 0 <= k < i <= j < arr.Length ==> arr[k] <= arr[j]
      invariant multiset(arr[..]) == multiset(old(arr[..]))
      decreases arr.Length - i
    {
      var minIdx := i;
      var j := i + 1;
      while j < arr.Length
        invariant i <= minIdx < arr.Length
        invariant i + 1 <= j <= arr.Length
        invariant sorted(arr[..i])
        invariant forall k, j0 :: 0 <= k < i <= j0 < arr.Length ==> arr[k] <= arr[j0]
        invariant forall k :: i <= k < j ==> arr[minIdx] <= arr[k]
        invariant multiset(arr[..]) == multiset(old(arr[..]))
        decreases arr.Length - j
      {
        if arr[j] < arr[minIdx] {
          minIdx := j;
        }
        j := j + 1;
      }
      if minIdx != i {
        var tmp := arr[i];
        arr[i] := arr[minIdx];
        arr[minIdx] := tmp;
      }
      i := i + 1;
    }
  }
}
