method ArrayExample() 
{
  // Simple array with explicit type
  var arr1: array<int> := new int[5];
  
  // 2D array in Dafny - using array of arrays
  var arr2: array<array<int>> := new array<array<int>>[3];
  var j: int := 0;
  while j < arr2.Length
    invariant 0 <= j <= arr2.Length
  {
    arr2[j] := new int[4];
    j := j + 1;
  }
  
  // Array of arrays with explicit type
  var arr3: array<array<int>> := new array<array<int>>[3];
  
  // Initialize the array of arrays
  var i: int := 0;
  while i < arr3.Length
    invariant 0 <= i <= arr3.Length
  {
    arr3[i] := new int[4];
    i := i + 1;
  }
  
  // Example usage
  arr1[0] := 1;
  arr2[0][0] := 2;
  arr3[0][0] := 3;
  
  // Assertions with proper types
  assert arr1[0] == 1;
  assert arr2[0][0] == 2;
  assert arr3[0][0] == 3;
}