module BinarySearch {

  predicate isSorted(arr: array<int>)
    requires arr != null
    reads arr
  {
    // This definition, using i <= j, is strong enough to reason about
    // any prefix or suffix of the array during the search.
    forall i, j :: 0 <= i <= j < arr.Length ==> arr[i] <= arr[j]
  }

  method BinarySearch(arr: array<int>, K: int) returns (found: bool)
    requires arr != null
    requires isSorted(arr)
    ensures found ==> exists i :: 0 <= i < arr.Length && arr[i] == K
    ensures !found ==> forall i :: 0 <= i < arr.Length ==> arr[i] != K
  {
    var low := 0;
    var high := arr.Length;
    found := false;

    while low < high
      invariant 0 <= low <= high <= arr.Length
      invariant forall i :: 0 <= i < low ==> arr[i] < K
      invariant forall i :: high <= i < arr.Length ==> arr[i] > K
    {
      var mid := low + (high - low) / 2;
      var v := arr[mid];
      if v == K {
        return true;
      } else if v < K {
        // Since arr[mid] < K and the array is sorted,
        // all indices up to mid also hold values < K.
        low := mid + 1;
      } else {
        // Since arr[mid] > K and the array is sorted,
        // all indices from mid onward hold values > K.
        high := mid;
      }
    }

    // If we exit the loop, low == high and the invariants
    // imply that no element equals K.
    return false;
  }
}
