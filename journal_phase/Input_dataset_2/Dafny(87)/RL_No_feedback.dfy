class MyClass {
  var array: array2<int>
  
  constructor() 
    ensures forall i, j :: 0 <= i < 5 && 0 <= j < 5 ==> array[i, j] == i + 1
  {
    array := new int[5, 5](_);
    // Initialize array
    var i: int := 0;
    while i < 5
      invariant 0 <= i <= 5
      invariant forall ii, jj :: 0 <= ii < i && 0 <= jj < 5 ==> array[ii, jj] == ii + 1
    {
      var j: int := 0;
      while j < 5
        invariant 0 <= j <= 5
        invariant forall jj :: 0 <= jj < j ==> array[i, jj] == i + 1
        invariant forall ii, jj :: 0 <= ii < i && 0 <= jj < 5 ==> array[ii, jj] == ii + 1
      {
        array[i, j] := i + 1;
        j := j + 1;
      }
      i := i + 1;
    }
  }

  method ModifyArray(M: int) 
    requires 0 <= M < 5
    modifies this
    ensures forall i, j :: 0 <= i < 5 && 0 <= j < 5 && (i != M || j >= 2) ==> array[i, j] == old(array[i, j])
    ensures forall j :: 0 <= j < 2 ==> array[M, j] == old(array[M, j]) + 1
  {
    var j: int := 0;
    while j < 2
      invariant 0 <= j <= 2
      invariant forall k :: 0 <= k < j ==> array[M, k] == old(array[M, k]) + 1
      invariant forall k :: j <= k < 2 ==> array[M, k] == old(array[M, k])
      invariant forall i, k :: 0 <= i < 5 && 0 <= k < 5 && (i != M || k >= 2) ==> array[i, k] == old(array[i, k])
    {
      array[M, j] := array[M, j] + 1;
      j := j + 1;
    }
  }
}

method Main() {
  var a := new MyClass();
  
  // Precondition: array indices are within bounds
  assert 0 <= 0 < 5 && 0 <= 0 < 5;
  assert 0 <= 0 < 5 && 0 <= 1 < 5;
  assert 0 <= 1 < 5 && 0 <= 0 < 5;
  assert 0 <= 1 < 5 && 0 <= 1 < 5;
  
  // Initial array values - i + 1 for all elements
  assert a.array[0, 0] == 1 && a.array[0, 1] == 1;
  assert a.array[1, 0] == 2 && a.array[1, 1] == 2;
  
  // Verify the constructor postcondition
  assert forall i, j :: 0 <= i < 5 && 0 <= j < 5 ==> a.array[i, j] == i + 1;
  
  // Modify array for M = 0
  a.ModifyArray(0);
  
  // Postcondition: verify array was updated correctly
  assert a.array[0, 0] == 2 && a.array[0, 1] == 2; // Modified (was 1,1 now 2,2)
  assert a.array[1, 0] == 2 && a.array[1, 1] == 2; // Unmodified (still 2,2)
  
  // Assertion: array remains unmodified outside the loop range
  assert forall i, j :: 0 <= i < 5 && 0 <= j < 5 && (i != 0 || j >= 2) ==> a.array[i, j] == i + 1;
  
  // Additional verification for the modified elements
  assert forall j :: 0 <= j < 2 ==> a.array[0, j] == 2;
  
  // Print some values to verify
  print a.array[0, 0], " ", a.array[0, 1], " ", a.array[1, 0], " ", a.array[1, 1], "\n";
}