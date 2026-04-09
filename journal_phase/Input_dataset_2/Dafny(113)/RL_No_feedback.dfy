method FindZero(a: array<int>) returns (index: int)
  ensures index == -1 || (0 <= index < a.Length && a[index] == 0)
  ensures index == -1 ==> forall i | 0 <= i < a.Length :: a[i] != 0
  ensures index != -1 ==> forall i | 0 <= i < index :: a[i] != 0
{
  var i := 0;
  index := -1;
  
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant index == -1 || (0 <= index < a.Length && a[index] == 0)
    invariant index == -1 ==> forall j | 0 <= j < i :: a[j] != 0
    invariant index != -1 ==> forall j | 0 <= j < index :: a[j] != 0
  {
    if a[i] == 0 {
      index := i;
      return;
    }
    
    // We know a[i] != 0 from the if condition above
    assert a[i] != 0;
    var skip := SkippingLemma(a, i);
    
    if skip > i {
      i := skip;
    } else {
      i := i + 1;
    }
  }
}

method SkippingLemma(a: array<int>, start: int) returns (next: int)
  requires 0 <= start < a.Length
  requires a[start] != 0
  ensures start < next <= a.Length
  ensures forall i | start <= i < next :: a[i] != 0
  decreases a.Length - start
{
  next := start + 1;
  
  while next < a.Length && a[next] != 0
    invariant start < next <= a.Length
    invariant forall i | start <= i < next :: a[i] != 0
    decreases a.Length - next
  {
    next := next + 1;
  }
}