method ArrayExample(n: int) returns (result: int)
  requires n > 0
  ensures result == n * (n - 1) / 2  // Sum of 0..(n-1)
{
  // 1. Array declaration with initial state
  var arr := new int[n];
  
  // 2. Initial state invariant
  ghost var initialValues := arr[..];
  assert arr.Length == n;
  assert forall i | 0 <= i < n :: arr[i] == 0;
  
  var sum := 0;
  var i := 0;
  
  // 3. Loop with array modifications
  while i < n
    invariant 0 <= i <= n
    invariant sum == (i - 1) * i / 2  // Sum of 0..(i-1)
    invariant forall j | 0 <= j < i :: arr[j] == j
    invariant forall j | i <= j < n :: arr[j] == 0
    decreases n - i
  {
    // 4. Single array modification per iteration
    arr[i] := i;
    sum := sum + i;
    i := i + 1;
    
    // 5. Intermediate state verification
    assert i <= n ==> (forall j | 0 <= j < i :: arr[j] == j);
  }
  
  // 6. Final state assertions
  assert i == n;
  assert forall j | 0 <= j < n :: arr[j] == j;
  assert sum == n * (n - 1) / 2;
  
  result := sum;
  
  // 7. Post-condition verification
  assert result == n * (n - 1) / 2;
}

// Alternative: Method with array parameter
method ProcessArray(a: array<int>) returns (modified: array<int>)
  ensures modified.Length == a.Length
  ensures forall i | 0 <= i < a.Length :: modified[i] == a[i] * 2
{
  modified := new int[a.Length];
  var i := 0;
  
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall j | 0 <= j < i :: modified[j] == a[j] * 2
    invariant forall j | i <= j < a.Length :: modified[j] == 0
    decreases a.Length - i
  {
    modified[i] := a[i] * 2;
    i := i + 1;
  }
}

// Example with nested scope - CORRECTED VERSION
method NestedScopeExample() {
  var outerArray := new int[10];
  
  // Initialize all elements to 0 (implicit in Dafny)
  // Outer scope
  {
    var i := 0;
    while i < 5
      invariant 0 <= i <= 5
      invariant forall j | 0 <= j < i :: outerArray[j] == 1
      invariant forall j | i <= j < outerArray.Length :: outerArray[j] == 0
      decreases 5 - i
    {
      outerArray[i] := 1;
      i := i + 1;
    }
  }
  
  // Inner scope with local array
  {
    var localArray := new int[5];
    var j := 0;
    while j < 5
      invariant 0 <= j <= 5
      invariant forall k | 0 <= k < j :: localArray[k] == 2
      invariant forall k | j <= k < localArray.Length :: localArray[k] == 0
      decreases 5 - j
    {
      localArray[j] := 2;
      j := j + 1;
    }
    
    // localArray goes out of scope here
  }
  
  // Additional nested loop example with proper termination
  {
    var k := 0;
    while k < outerArray.Length
      invariant 0 <= k <= outerArray.Length
      invariant forall m | 0 <= m < k :: outerArray[m] == 1
      invariant forall m | k <= m < outerArray.Length :: outerArray[m] == 0
      decreases outerArray.Length - k  // Fixed: proper termination measure
    {
      if k < 5 {
        // Already set to 1 in first loop
      } else {
        outerArray[k] := 3;  // Set remaining elements to 3
      }
      k := k + 1;
    }
  }
  
  // outerArray still accessible - This assertion should now hold
  assert outerArray[0] == 1;
  assert outerArray[5] == 3;  // Elements from index 5 onward should be 3
}

// Helper lemma for array properties
lemma ArrayProperties(a: array<int>)
  ensures |a[..]| == a.Length
  ensures forall i | 0 <= i < a.Length :: a[..][i] == a[i]
{
}

// Method demonstrating array slicing
method ArraySliceExample(a: array<int>) returns (slice: array<int>)
  requires a.Length >= 4  // Fixed: need at least 4 elements for indices 1,2,3
  ensures slice.Length == 3
  ensures slice[0] == a[1] && slice[1] == a[2] && slice[2] == a[3]
{
  slice := new int[3];
  slice[0] := a[1];
  slice[1] := a[2];
  slice[2] := a[3];
}