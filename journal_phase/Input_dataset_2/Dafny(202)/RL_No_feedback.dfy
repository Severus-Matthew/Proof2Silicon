method ArrayExample(a: array<int>) 
  modifies a
  ensures forall i :: 0 <= i < a.Length ==> a[i] == old(a[i])
{
  // First, copy original values to preserve them
  var original := new int[a.Length];
  var i := 0;
  
  // Copy original values from a to original array
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall j :: 0 <= j < i ==> original[j] == a[j]
    invariant forall j :: 0 <= j < a.Length ==> a[j] == old(a[j])
  {
    original[i] := a[i];
    i := i + 1;
  }
  
  // Now we can modify a as needed
  i := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall j :: 0 <= j < a.Length ==> original[j] == old(a[j])
  {
    // Example modification: increment each element
    a[i] := a[i] + 1;
    i := i + 1;
  }
  
  // Restore original values
  i := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall j :: 0 <= j < i ==> a[j] == original[j]
    invariant forall j :: i <= j < a.Length ==> original[j] == old(a[j])
  {
    a[i] := original[i];
    i := i + 1;
  }
}