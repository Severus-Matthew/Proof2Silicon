module SortingDemo {

  // A pure function to describe sortedness on a segment [lo, hi)
  predicate Sorted(a: array<int>, lo: int, hi: int)
    requires a != null
    requires 0 <= lo <= hi <= a.Length
    reads a
  {
    forall i, j :: lo <= i <= j < hi ==> a[i] <= a[j]
  }

  // A pure function to describe permutation via multiset equality
  predicate PermutationOf(oldA: seq<int>, newA: seq<int>)
  {
    multiset(oldA) == multiset(newA)
  }

  method SelectionSort(a: array<int>)
    requires a != null
    modifies a
    ensures Sorted(a, 0, a.Length)
    ensures PermutationOf(old(a[..]), a[..])
  {
    var n := a.Length;
    var i := 0;
    while i < n
      invariant 0 <= i <= n
      invariant Sorted(a, 0, i)
      invariant forall p, q :: 0 <= p < i <= q < n ==> a[p] <= a[q]
      invariant PermutationOf(old(a[..]), a[..])
      decreases n - i
    {
      var minIdx := i;
      var j := i + 1;

      while j < n
        invariant i + 1 <= j <= n
        invariant i <= minIdx < n
        invariant forall k :: i <= k < j ==> a[minIdx] <= a[k]
        invariant Sorted(a, 0, i)
        invariant forall p, q :: 0 <= p < i <= q < n ==> a[p] <= a[q]
        invariant PermutationOf(old(a[..]), a[..])
        decreases n - j
      {
        if a[j] < a[minIdx] {
          minIdx := j;
        }
        j := j + 1;
      }

      if minIdx != i {
        var tmp := a[i];
        a[i] := a[minIdx];
        a[minIdx] := tmp;
      }

      // Establish boundary property for new prefix element
      assert forall q :: i <= q < n ==> a[i] <= a[q];

      i := i + 1;
    }
  }

  method Main()
  {
    var a := new int[8];
    a[0] := 5;
    a[1] := 2;
    a[2] := 9;
    a[3] := 1;
    a[4] := 5;
    a[5] := 6;
    a[6] := 0;
    a[7] := 3;

    var before := a[..];
    SelectionSort(a);

    // Demonstrate correctness conditions after sorting
    assert Sorted(a, 0, a.Length);
    assert PermutationOf(before, a[..]);

    // Additional concrete checks
    assert a[0] <= a[1];
    assert a[1] <= a[2];
    assert a[2] <= a[3];
    assert a[3] <= a[4];
    assert a[4] <= a[5];
    assert a[5] <= a[6];
    assert a[6] <= a[7];
  }
}
