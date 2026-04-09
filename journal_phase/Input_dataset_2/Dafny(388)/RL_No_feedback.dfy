method LastPosition(arr: array<int>, elem: int) returns (index: int)
  ensures index == -1 || (0 <= index < arr.Length && arr[index] == elem)
  ensures index == -1 ==> forall i :: 0 <= i < arr.Length ==> arr[i] != elem
  ensures index != -1 ==> forall i :: index < i < arr.Length ==> arr[i] != elem
{
  index := -1;
  var i: int := 0;
  
  while i < arr.Length
    invariant 0 <= i <= arr.Length
    invariant index == -1 ==> forall j :: 0 <= j < i ==> arr[j] != elem
    invariant index != -1 ==> (
      0 <= index < i && 
      arr[index] == elem && 
      forall j :: index < j < i ==> arr[j] != elem
    )
    decreases arr.Length - i
  {
    if arr[i] == elem {
      index := i;
    }
    i := i + 1;
  }
}