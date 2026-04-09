method SearchLoop(seq: seq<int>, target: int) returns (index: int)
  requires |seq| > 0  // sequence is not empty
  ensures -1 <= index < |seq|  // index is within bounds or -1
  ensures index == -1 ==> (forall i :: 0 <= i < |seq| ==> seq[i] != target)  // if -1, target not found
  ensures index != -1 ==> (0 <= index < |seq| && seq[index] == target)  // if not -1, found at index
{
  index := -1;
  var i := 0;
  
  while i < |seq|
    invariant 0 <= i <= |seq|
    invariant index == -1 ==> (forall j :: 0 <= j < i ==> seq[j] != target)
    invariant index != -1 ==> (0 <= index < i && seq[index] == target)
  {
    if seq[i] == target {
      index := i;
      return;
    }
    i := i + 1;
  }
}