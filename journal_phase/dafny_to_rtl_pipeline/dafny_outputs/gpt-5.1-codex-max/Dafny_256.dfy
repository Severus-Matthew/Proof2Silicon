function equals<T(==)>(x: seq<T>, y: seq<T>): bool {
  x == y
}

method ContainsSequence(list: seq<seq<int>>, sub: seq<int>) returns (found: bool)
  ensures found ==> exists i :: 0 <= i < |list| && list[i] == sub
  ensures !found ==> forall i :: 0 <= i < |list| ==> list[i] != sub
{
  var i := 0;
  found := false;
  while i < |list| && !found
    invariant 0 <= i <= |list|
    invariant found ==> exists k :: 0 <= k < i && list[k] == sub
    invariant !found ==> forall k :: 0 <= k < i ==> list[k] != sub
    decreases |list| - i
  {
    if list[i] == sub {
      found := true;
    }
    i := i + 1;
  }
}
