method SearchLoop(a: seq<int>, x: int) returns (k: int)
  requires |a| > 0
  requires forall i, j :: 0 <= i < j < |a| ==> a[i] >= a[j]
  ensures 0 <= k <= |a|
  ensures forall i :: 0 <= i < k ==> a[i] >= x
  ensures forall i :: k <= i < |a| ==> a[i] < x
{
  var left := 0;
  var right := |a|;
  
  while left < right
    invariant 0 <= left <= right <= |a|
    invariant forall i :: 0 <= i < left ==> a[i] >= x
    invariant forall i :: right <= i < |a| ==> a[i] < x
  {
    var mid := left + (right - left) / 2;
    if a[mid] >= x {
      left := mid + 1;
    } else {
      right := mid;
    }
  }
  
  k := left;
}

method SearchRecursive(a: seq<int>, x: int) returns (k: int)
  requires |a| > 0
  requires forall i, j :: 0 <= i < j < |a| ==> a[i] >= a[j]
  ensures 0 <= k <= |a|
  ensures forall i :: 0 <= i < k ==> a[i] >= x
  ensures forall i :: k <= i < |a| ==> a[i] < x
{
  k := SearchRecursiveHelper(a, x, 0, |a|);
}

function SearchRecursiveHelper(a: seq<int>, x: int, left: int, right: int): int
  requires 0 <= left <= right <= |a|
  requires forall i, j :: 0 <= i < j < |a| ==> a[i] >= a[j]
  ensures left <= SearchRecursiveHelper(a, x, left, right) <= right
  ensures forall i :: 0 <= i < left ==> a[i] >= x
  ensures forall i :: left <= i < SearchRecursiveHelper(a, x, left, right) ==> a[i] >= x
  ensures forall i :: SearchRecursiveHelper(a, x, left, right) <= i < right ==> a[i] < x
  ensures forall i :: right <= i < |a| ==> a[i] < x
  decreases right - left
{
  if left >= right then
    left
  else
    var mid := left + (right - left) / 2;
    if a[mid] >= x then
      SearchRecursiveHelper(a, x, mid + 1, right)
    else
      SearchRecursiveHelper(a, x, left, mid)
}

method Test() {
  var a := [10, 8, 8, 7, 5, 3, 2, 1];
  
  // Verify sequence is non-increasing
  assert forall i, j :: 0 <= i < j < |a| ==> a[i] >= a[j];
  
  // Test various cases for SearchLoop
  var k1 := SearchLoop(a, 8);
  assert 0 <= k1 <= |a|;
  assert forall i :: 0 <= i < k1 ==> a[i] >= 8;
  assert forall i :: k1 <= i < |a| ==> a[i] < 8;
  
  var k2 := SearchLoop(a, 10);
  assert 0 <= k2 <= |a|;
  assert forall i :: 0 <= i < k2 ==> a[i] >= 10;
  assert forall i :: k2 <= i < |a| ==> a[i] < 10;
  
  // Test various cases for SearchRecursive
  var k3 := SearchRecursive(a, 8);
  assert 0 <= k3 <= |a|;
  assert forall i :: 0 <= i < k3 ==> a[i] >= 8;
  assert forall i :: k3 <= i < |a| ==> a[i] < 8;
  
  var k4 := SearchRecursive(a, 10);
  assert 0 <= k4 <= |a|;
  assert forall i :: 0 <= i < k4 ==> a[i] >= 10;
  assert forall i :: k4 <= i < |a| ==> a[i] < 10;
}