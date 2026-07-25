module FirstZeroFinder {

  method FirstZeroIndex(a: array<int>) returns (idx: int)
    ensures (exists k :: 0 <= k < a.Length && a[k] == 0) ==>
              0 <= idx < a.Length &&
              a[idx] == 0 &&
              (forall j :: 0 <= j < idx ==> a[j] != 0)
    ensures (forall k :: 0 <= k < a.Length ==> a[k] != 0) ==> idx == -1
  {
    var i := 0;
    // Scan the array from left to right until a zero is found or the end is reached
    while i < a.Length
      invariant 0 <= i <= a.Length
      invariant forall j :: 0 <= j < i ==> a[j] != 0
      decreases a.Length - i
    {
      if a[i] == 0 {
        idx := i;
        return;
      }
      i := i + 1;
    }
    // No zero was found
    idx := -1;
  }

  method Main() {
    var arr := new int[5];
    arr[0] := 1;
    arr[1] := 2;
    arr[2] := 0;
    arr[3] := 3;
    arr[4] := 0;

    var res := FirstZeroIndex(arr);

    // From the postcondition of FirstZeroIndex and the concrete contents of arr,
    // we can prove that res == 2.
    assert res >= 0 && res < arr.Length;     // there is at least one zero
    assert arr[res] == 0;                    // returned position is a zero
    assert res != 0;                         // arr[0] = 1
    assert res != 1;                         // arr[1] = 2
    assert res != 3;                         // arr[3] = 3
    // If res > 2, then by the postcondition we would have arr[2] != 0, contradiction
    if res > 2 {
      assert 2 < res;
      assert forall j :: 0 <= j < res ==> arr[j] != 0; // from postcondition
      assert arr[2] != 0;                              // instantiation with j = 2
    }
    assert res <= 2;
    assert res == 2;
  }
}
