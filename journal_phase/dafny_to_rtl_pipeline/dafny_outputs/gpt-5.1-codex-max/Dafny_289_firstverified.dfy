method ElementWiseDivision(a: seq<int>, b: seq<int>) returns (c: seq<int>)
  requires |a| == |b|
  requires forall i :: 0 <= i < |b| ==> b[i] != 0
  ensures |c| == |a|
  ensures forall i :: 0 <= i < |c| ==> c[i] == a[i] / b[i]
{
  var arr := new int[|a|];
  var i := 0;
  while i < |a|
    invariant 0 <= i <= |a|
    invariant forall k :: 0 <= k < i ==> arr[k] == a[k] / b[k]
  {
    arr[i] := a[i] / b[i];
    i := i + 1;
  }
  c := arr[..];
}
