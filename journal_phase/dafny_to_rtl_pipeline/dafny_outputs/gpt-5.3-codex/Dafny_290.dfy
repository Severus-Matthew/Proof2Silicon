method SplitArray(arr: array<int>, L: int) returns (firstPart: seq<int>, secondPart: seq<int>)
  requires arr != null
  requires 0 <= L <= arr.Length
  ensures |firstPart| == L
  ensures |secondPart| == arr.Length - L
  ensures firstPart + secondPart == arr[..]
{
  firstPart := [];
  secondPart := [];

  var i := 0;
  while i < L
    invariant 0 <= i <= L
    invariant |firstPart| == i
    invariant firstPart == arr[..i]
    decreases L - i
  {
    firstPart := firstPart + [arr[i]];
    i := i + 1;
  }

  i := L;
  while i < arr.Length
    invariant L <= i <= arr.Length
    invariant |secondPart| == i - L
    invariant secondPart == arr[L..i]
    decreases arr.Length - i
  {
    secondPart := secondPart + [arr[i]];
    i := i + 1;
  }

  assert firstPart == arr[..L];
  assert secondPart == arr[L..];
  assert firstPart + secondPart == arr[..L] + arr[L..];
  assert arr[..L] + arr[L..] == arr[..];
}
