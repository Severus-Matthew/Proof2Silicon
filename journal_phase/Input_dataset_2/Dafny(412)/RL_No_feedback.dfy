predicate quickSorted(s: seq<int>)
{
  forall i, j :: 0 <= i < j < |s| ==> s[i] <= s[j]
}

method quickSort(s: seq<int>) returns (result: seq<int>)
  ensures quickSorted(result)
  ensures multiset(result) == multiset(s)
  decreases |s|
{
  if |s| <= 1 {
    result := s;
  } else {
    var pivot := s[|s| / 2];
    var lt, eq, gt := threshold(s, pivot);
    
    var sorted_lt := quickSort(lt);
    var sorted_gt := quickSort(gt);
    
    result := sorted_lt + eq + sorted_gt;
  }
}

method threshold(s: seq<int>, pivot: int) 
  returns (lt: seq<int>, eq: seq<int>, gt: seq<int>)
  ensures multiset(lt) + multiset(eq) + multiset(gt) == multiset(s)
  ensures forall x :: x in lt ==> x < pivot
  ensures forall x :: x in eq ==> x == pivot
  ensures forall x :: x in gt ==> x > pivot
  decreases |s|
{
  lt := [];
  eq := [];
  gt := [];
  
  var i := 0;
  while i < |s|
    invariant 0 <= i <= |s|
    invariant multiset(lt) + multiset(eq) + multiset(gt) == multiset(s[..i])
    invariant forall x :: x in lt ==> x < pivot
    invariant forall x :: x in eq ==> x == pivot
    invariant forall x :: x in gt ==> x > pivot
  {
    if s[i] < pivot {
      lt := lt + [s[i]];
    } else if s[i] == pivot {
      eq := eq + [s[i]];
    } else {
      gt := gt + [s[i]];
    }
    i := i + 1;
  }
}