method FindMax(array: array<real>) returns (maxIndex: int)
  requires array.Length > 0
  ensures 0 <= maxIndex < array.Length
  ensures forall i :: 0 <= i < array.Length ==> array[i] <= array[maxIndex]
{
  var currentMax: real := array[0];
  maxIndex := 0;
  
  var i: int := 1;
  while i < array.Length
    invariant 1 <= i <= array.Length
    invariant 0 <= maxIndex < array.Length
    invariant array[maxIndex] == currentMax
    invariant forall j :: 0 <= j < i ==> array[j] <= currentMax
  {
    if array[i] > currentMax {
      currentMax := array[i];
      maxIndex := i;
    }
    i := i + 1;
  }
}

method Main() {
  // Test case 1
  var arr1: array<real> := new real[5];
  arr1[0] := 3.0; arr1[1] := 2.5; arr1[2] := 2.0; arr1[3] := 2.7; arr1[4] := 2.0;
  var idx1: int := FindMax(arr1);
  print "Array: [3.0, 2.5, 2.0, 2.7, 2.0]\n";
  print "Max index: ", idx1, ", Max value: ", arr1[idx1], "\n";
  assert arr1[idx1] >= arr1[0];
  
  // Test case 2
  var arr2: array<real> := new real[5];
  arr2[0] := 1.5; arr2[1] := 2.7; arr2[2] := 3.1; arr2[3] := 2.9; arr2[4] := 3.1;
  var idx2: int := FindMax(arr2);
  print "Array: [1.5, 2.7, 3.1, 2.9, 3.1]\n";
  print "Max index: ", idx2, ", Max value: ", arr2[idx2], "\n";
  assert arr2[idx2] >= arr2[0];
  
  // Test case 3
  var arr3: array<real> := new real[3];
  arr3[0] := -1.2; arr3[1] := -3.4; arr3[2] := -0.5;
  var idx3: int := FindMax(arr3);
  print "Array: [-1.2, -3.4, -0.5]\n";
  print "Max index: ", idx3, ", Max value: ", arr3[idx3], "\n";
  assert arr3[idx3] >= arr3[0];
  
  // Test case 4
  var arr4: array<real> := new real[4];
  arr4[0] := 0.0; arr4[1] := 0.0; arr4[2] := 0.0; arr4[3] := 0.0;
  var idx4: int := FindMax(arr4);
  print "Array: [0.0, 0.0, 0.0, 0.0]\n";
  print "Max index: ", idx4, ", Max value: ", arr4[idx4], "\n";
  assert arr4[idx4] >= arr4[0];
  
  // Additional test cases from instructions
  var arr5: array<real> := new real[5];
  arr5[0] := 4.0; arr5[1] := 2.0; arr5[2] := 3.0; arr5[3] := 1.0; arr5[4] := 5.0;
  var maxIdx1: int := FindMax(arr5);
  assert arr5[maxIdx1] >= arr5[0];
  
  var arr6: array<real> := new real[1];
  arr6[0] := 10.0;
  var maxIdx2: int := FindMax(arr6);
  assert arr6[maxIdx2] >= arr6[0];
}