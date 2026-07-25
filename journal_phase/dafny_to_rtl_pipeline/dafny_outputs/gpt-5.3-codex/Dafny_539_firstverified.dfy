module StepwiseTemplate {

  // Step 1: Define a simple iterative utility that computes the sum 0 + 1 + ... + n.
  method SumUpTo(n: nat) returns (s: nat)
    ensures s == n * (n + 1) / 2
  {
    var i: nat := 0;
    s := 0;

    while i < n
      invariant 0 <= i <= n
      invariant s == i * (i + 1) / 2
      decreases n - i
    {
      i := i + 1;
      s := s + i;
    }

    assert i == n;
    assert s == n * (n + 1) / 2;
  }

  // Step 2: Iteratively reverse an array into a fresh array (no recursion).
  method ReverseIntoFresh(a: array<int>) returns (b: array<int>)
    requires a != null
    ensures b != null
    ensures b.Length == a.Length
    ensures forall k :: 0 <= k < a.Length ==> b[k] == a[a.Length - 1 - k]
  {
    b := new int[a.Length];
    var i: int := 0;

    while i < a.Length
      invariant 0 <= i <= a.Length
      invariant b != null && b.Length == a.Length
      invariant forall k :: 0 <= k < i ==> b[k] == a[a.Length - 1 - k]
      decreases a.Length - i
    {
      b[i] := a[a.Length - 1 - i];
      i := i + 1;
    }
  }

  // Step 3: Find maximum element and its first index in a non-empty array.
  method MaxWithFirstIndex(a: array<int>) returns (maxVal: int, idx: nat)
    requires a != null
    requires a.Length > 0
    ensures 0 <= idx < a.Length
    ensures maxVal == a[idx]
    ensures forall k :: 0 <= k < a.Length ==> a[k] <= maxVal
    ensures forall k :: 0 <= k < idx ==> a[k] < maxVal
  {
    var i: int := 1;
    idx := 0;
    maxVal := a[0];

    while i < a.Length
      invariant 1 <= i <= a.Length
      invariant 0 <= idx < i
      invariant maxVal == a[idx]
      invariant forall k :: 0 <= k < i ==> a[k] <= maxVal
      invariant forall k :: 0 <= k < idx ==> a[k] < maxVal
      decreases a.Length - i
    {
      if a[i] > maxVal {
        maxVal := a[i];
        idx := i as nat;
      }
      i := i + 1;
    }
  }

  // Step 4: Demonstration method with assertions that help the verifier.
  method Demo()
  {
    var s := SumUpTo(10);
    assert s == 55;

    var arr := new int[5];
    arr[0], arr[1], arr[2], arr[3], arr[4] := 3, -1, 7, 7, 2;

    var rev := ReverseIntoFresh(arr);
    assert rev[0] == 2;
    assert rev[1] == 7;
    assert rev[2] == 7;
    assert rev[3] == -1;
    assert rev[4] == 3;

    var m, p := MaxWithFirstIndex(arr);
    assert m == 7;
    assert p == 2; // first occurrence of the maximum
  }
}
