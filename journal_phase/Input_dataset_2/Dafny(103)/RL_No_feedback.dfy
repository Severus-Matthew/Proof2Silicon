method LinearSearch0(a: array<int>) returns (index: int)
  ensures 0 <= index < a.Length
  ensures (exists i :: 0 <= i < a.Length && a[i] % 2 == 0) ==> a[index] % 2 == 0
  ensures !(exists i :: 0 <= i < a.Length && a[i] % 2 == 0) ==> a[index] % 2 != 0
  ensures forall i :: 0 <= i < index ==> a[i] % 2 != 0
{
  var firstEven := -1;
  index := 0;
  
  while index < a.Length
    invariant 0 <= index <= a.Length
    invariant firstEven == -1 || (0 <= firstEven < a.Length && a[firstEven] % 2 == 0)
    invariant firstEven == -1 ==> forall i :: 0 <= i < index ==> a[i] % 2 != 0
    invariant firstOdd != -1 ==> (firstEven < index && forall i :: 0 <= i < firstEven ==> a[i] % 2 != 0)
    decreases a.Length - index
  {
    if firstEven == -1 && a[index] % 2 == 0 {
      firstEven := index;
    }
    index := index + 1;
  }
  
  if firstEven != -1 {
    index := firstEven;
  } else {
    index := 0;
  }
}

method LinearSearch1(a: array<int>) returns (index: int)
  ensures 0 <= index < a.Length
  ensures (exists i :: 0 <= i < a.Length && a[i] % 2 != 0) ==> a[index] % 2 != 0
  ensures !(exists i :: 0 <= i < a.Length && a[i] % 2 != 0) ==> a[index] % 2 == 0
  ensures forall i :: 0 <= i < index ==> a[i] % 2 == 0
{
  var firstOdd := -1;
  index := 0;
  
  while index < a.Length
    invariant 0 <= index <= a.Length
    invariant firstOdd == -1 || (0 <= firstOdd < a.Length && a[firstOdd] % 2 != 0)
    invariant firstOdd == -1 ==> forall i :: 0 <= i < index ==> a[i] % 2 == 0
    invariant firstOdd != -1 ==> (firstOdd < index && forall i :: 0 <= i < firstOdd ==> a[i] % 2 == 0)
    decreases a.Length - index
  {
    if firstOdd == -1 && a[index] % 2 != 0 {
      firstOdd := index;
    }
    index := index + 1;
  }
  
  if firstOdd != -1 {
    index := firstOdd;
  } else {
    index := 0;
  }
}

method TestLinearSearch() 
{
  // Test case 1: all odd numbers
  var a1 := new int[5];
  a1[0] := 1;
  a1[1] := 3;
  a1[2] := 5;
  a1[3] := 7;
  a1[4] := 9;
  
  var index0 := LinearSearch0(a1);
  assert index0 == 0;
  assert a1[index0] % 2 != 0;
  
  // Test case 2: all even numbers
  var a2 := new int[5];
  a2[0] := 2;
  a2[1] := 4;
  a2[2] := 6;
  a2[3] := 8;
  a2[4] := 10;
  
  var index1 := LinearSearch1(a2);
  assert index1 == 0;
  assert a2[index1] % 2 == 0;
  
  // Test case 3: mixed numbers with first element odd
  var a3 := new int[5];
  a3[0] := 1;
  a3[1] := 2;
  a3[2] := 3;
  a3[3] := 4;
  a3[4] := 5;
  
  var index2 := LinearSearch0(a3);
  assert index2 == 1;
  assert a3[index2] % 2 == 0;
  
  var index3 := LinearSearch1(a3);
  assert index3 == 0;
  assert a3[index3] % 2 != 0;
  
  // Test case 4: mixed numbers with first element even
  var a4 := new int[5];
  a4[0] := 2;
  a4[1] := 1;
  a4[2] := 4;
  a4[3] := 3;
  a4[4] := 6;
  
  var index4 := LinearSearch0(a4);
  assert index4 == 0;
  assert a4[index4] % 2 == 0;
  
  var index5 := LinearSearch1(a4);
  assert index5 == 1;
  assert a4[index5] % 2 != 0;
  
  // Test case 5: array with even number in middle
  var a5 := new int[6];
  a5[0] := 1;
  a5[1] := 3;
  a5[2] := 4;
  a5[3] := 6;
  a5[4] := 7;
  a5[5] := 9;
  
  var index6 := LinearSearch0(a5);
  assert index6 == 2;
  assert a5[index6] % 2 == 0;
  
  // Test case 6: array from instructions
  var b := new int[5];
  b[0] := 9;
  b[1] := 8;
  b[2] := 7;
  b[3] := 6;
  b[4] := 5;
  
  var index7 := LinearSearch0(b);
  assert b[index7] % 2 == 0;
  
  var index8 := LinearSearch1(b);
  assert b[index8] % 2 != 0;
}