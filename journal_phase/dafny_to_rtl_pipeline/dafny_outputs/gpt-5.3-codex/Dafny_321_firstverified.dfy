module FindNegativeNumbers {

  method FindNegativeNumbers(arr: array<int>) returns (negIdx: seq<int>)
    requires arr != null
    ensures forall k :: 0 <= k < |negIdx| ==> 0 <= negIdx[k] < arr.Length
    ensures forall k :: 0 <= k < |negIdx| ==> arr[negIdx[k]] < 0
    ensures forall i :: 0 <= i < arr.Length && arr[i] < 0 ==> i in negIdx
    ensures forall i,j :: 0 <= i < j < |negIdx| ==> negIdx[i] < negIdx[j]
  {
    var i := 0;
    negIdx := [];

    while i < arr.Length
      invariant 0 <= i <= arr.Length
      invariant forall k :: 0 <= k < |negIdx| ==> 0 <= negIdx[k] < i
      invariant forall k :: 0 <= k < |negIdx| ==> arr[negIdx[k]] < 0
      invariant forall j :: 0 <= j < i && arr[j] < 0 ==> j in negIdx
      invariant forall a,b :: 0 <= a < b < |negIdx| ==> negIdx[a] < negIdx[b]
      decreases arr.Length - i
    {
      if arr[i] < 0 {
        negIdx := negIdx + [i];
      }
      i := i + 1;
    }
  }
}
