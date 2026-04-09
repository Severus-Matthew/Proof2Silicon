method VerifyLoopBoundsAndAssertions(n: int) returns (sum: int)
  requires n >= 0
  ensures sum == n * (n + 1) / 2
{
  var i := 0;
  sum := 0;
  
  while i <= n
    invariant 0 <= i <= n + 1
    invariant sum == i * (i - 1) / 2
    decreases n - i
  {
    sum := sum + i;
    i := i + 1;
  }
}

method CompareAndSwap(a: array<int>) 
  requires a.Length >= 2
  ensures a[0] <= a[1]
{
  if (a[1] < a[0]) {
    var temp := a[0];
    a[0] := a[1];
    a[1] := temp;
  }
}

method VerifyInductiveProperty(n: int) returns (result: int)
  requires n >= 0
  ensures result == n
{
  result := 0;
  var counter := 0;
  
  while counter < n
    invariant 0 <= counter <= n
    invariant result == counter
    decreases n - counter
  {
    result := result + 1;
    counter := counter + 1;
  }
}

method VerifyArrayBounds(arr: array<int>) 
  requires arr.Length > 0
{
  var i := 0;
  
  while i < arr.Length
    invariant 0 <= i <= arr.Length
    decreases arr.Length - i
  {
    var element := arr[i];
    i := i + 1;
  }
}

method Main()
{
  var sum1 := VerifyLoopBoundsAndAssertions(5);
  assert sum1 == 15;
  
  var arr := new int[2];
  arr[0] := 5;
  arr[1] := 3;
  CompareAndSwap(arr);
  assert arr[0] == 3 && arr[1] == 5;
  
  var result := VerifyInductiveProperty(10);
  assert result == 10;
  
  var testArr := new int[3];
  testArr[0] := 1;
  testArr[1] := 2;
  testArr[2] := 3;
  VerifyArrayBounds(testArr);
}