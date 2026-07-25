method SplitArray(arr: array<int>, L: int) returns (firstPart: seq<int>, secondPart: seq<int>)
  requires arr != null
  requires 0 <= L <= arr.Length
  ensures firstPart == arr[..L]
  ensures secondPart == arr[L..]
  ensures |firstPart| == L
  ensures |secondPart| == arr.Length - L
  ensures firstPart + secondPart == arr[..]
{
  firstPart := arr[..L];
  secondPart := arr[L..];
}
