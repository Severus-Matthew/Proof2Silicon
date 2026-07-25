module BinarySearchModule {

  // A helper predicate: array segment a[lo..hi) is sorted in nondecreasing order.
  predicate Sorted(a: array<int>, lo: int, hi: int)
    requires a != null
    requires 0 <= lo <= hi <= a.Length
    reads a
  {
    forall i, j :: lo <= i <= j < hi ==> a[i] <= a[j]
  }

  // Binary search over a sorted array.
  // Returns:
  //   - index i with a[i] == key, if key exists
  //   - -1 otherwise
  method BinarySearch(a: array<int>, key: int) returns (idx: int)
    requires a != null
    requires Sorted(a, 0, a.Length)
    ensures -1 <= idx < a.Length
    ensures idx >= 0 ==> a[idx] == key
    ensures idx == -1 ==> forall k :: 0 <= k < a.Length ==> a[k] != key
  {
    var lo := 0;
    var hi := a.Length; // Search interval is [lo, hi)

    while lo < hi
      invariant 0 <= lo <= hi <= a.Length
      invariant forall k :: 0 <= k < lo ==> a[k] < key
      invariant forall k :: hi <= k < a.Length ==> a[k] > key
      decreases hi - lo
    {
      var mid := lo + (hi - lo) / 2;
      assert lo <= mid < hi;

      if a[mid] == key {
        idx := mid;
        return;
      } else if a[mid] < key {
        // Exclude [lo..mid], all are < key by sortedness and a[mid] < key
        lo := mid + 1;
      } else {
        // a[mid] > key, exclude [mid..hi), all are > key by sortedness
        hi := mid;
      }
    }

    // Not found
    idx := -1;
  }

  // Check function to verify correctness on representative test cases.
  // Uses assertions to validate postconditions behavior.
  method CheckBinarySearch()
  {
    var a := new int[7];
    a[0], a[1], a[2], a[3], a[4], a[5], a[6] := 1, 3, 5, 7, 9, 11, 13;
    assert Sorted(a, 0, a.Length);

    var i := BinarySearch(a, 1);
    assert i == 0;
    assert a[i] == 1;

    i := BinarySearch(a, 7);
    assert i == 3;
    assert a[i] == 7;

    i := BinarySearch(a, 13);
    assert i == 6;
    assert a[i] == 13;

    i := BinarySearch(a, 8);
    assert i == -1;
    assert forall k :: 0 <= k < a.Length ==> a[k] != 8;

    var b := new int[0];
    assert Sorted(b, 0, b.Length);
    i := BinarySearch(b, 42);
    assert i == -1;

    var c := new int[5];
    c[0], c[1], c[2], c[3], c[4] := 2, 2, 2, 2, 2;
    assert Sorted(c, 0, c.Length);

    i := BinarySearch(c, 2);
    assert 0 <= i < c.Length;
    assert c[i] == 2;

    i := BinarySearch(c, 3);
    assert i == -1;
    assert forall k :: 0 <= k < c.Length ==> c[k] != 3;
  }
}
