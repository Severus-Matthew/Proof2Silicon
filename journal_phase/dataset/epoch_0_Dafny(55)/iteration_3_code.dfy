module Program {
  method ToArray<T>(s: seq<T>) returns (arr: array<T>)
    ensures arr.Length == |s|
    ensures forall i :: 0 <= i < |s| ==> arr[i] == s[i]
  {
    arr := new T[|s|];
    var i := 0;
    while i < |s|
      invariant 0 <= i <= |s|
      invariant forall j :: 0 <= j < i ==> arr[j] == s[j]
    {
      arr[i] := s[i];
      i := i + 1;
    }
  }

  method TestToArray() {
    var seq1 := [1, 2, 3, 4, 5];
    var arr1 := ToArray(seq1);
    
    // Verify the array contains the same elements
    assert arr1.Length == 5;
    assert arr1[0] == 1;
    assert arr1[1] == 2;
    assert arr1[2] == 3;
    assert arr1[3] == 4;
    assert arr1[4] == 5;
    
    // Alternative verification using a loop
    var i := 0;
    while i < arr1.Length
      invariant 0 <= i <= arr1.Length
      invariant forall j :: 0 <= j < i ==> arr1[j] == seq1[j]
    {
      assert arr1[i] == seq1[i];
      i := i + 1;
    }
  }
}