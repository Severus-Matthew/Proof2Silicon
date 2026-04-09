method ProcessLists(list1: array<int>, list2: array<int>) returns (result: array<int>)
  requires list1.Length == list2.Length
  ensures result.Length == list1.Length + list2.Length
  ensures forall i :: 0 <= i < list1.Length ==> result[2*i] == list1[i]
  ensures forall i :: 0 <= i < list2.Length ==> result[2*i + 1] == list2[i]
{
  var length := list1.Length;
  result := new int[2 * length];
  
  var i: int := 0;
  while i < length
    invariant 0 <= i <= length
    invariant forall j :: 0 <= j < i ==> result[2*j] == list1[j]
    invariant forall j :: 0 <= j < i ==> result[2*j + 1] == list2[j]
  {
    result[2*i] := list1[i];
    result[2*i + 1] := list2[i];
    i := i + 1;
  }
}

method Main()
{
  var list1: array<int> := new int[3];
  list1[0] := 1;
  list1[1] := 3;
  list1[2] := 5;
  
  var list2: array<int> := new int[3];
  list2[0] := 2;
  list2[1] := 4;
  list2[2] := 6;
  
  var result: array<int>;
  result := ProcessLists(list1, list2);
  
  // Verification
  assert result[0] == 1;  // from list1[0]
  assert result[1] == 2;  // from list2[0]
  assert result[2] == 3;  // from list1[1]
  assert result[3] == 4;  // from list2[1]
  assert result[4] == 5;  // from list1[2]
  assert result[5] == 6;  // from list2[2]
}