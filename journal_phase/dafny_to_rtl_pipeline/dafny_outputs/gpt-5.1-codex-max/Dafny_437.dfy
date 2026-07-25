method Max(s: seq<int>) returns (m: int)
  requires |s| > 0
  ensures forall i:int :: 0 <= i < |s| ==> s[i] <= m
  ensures m in s
{
  m := s[0];
  var i := 1;
  while i < |s|
    invariant 1 <= i && i <= |s|
    invariant m in s[..i]
    invariant forall j:int :: 0 <= j < i ==> s[j] <= m
    decreases |s| - i
  {
    if s[i] > m {
      m := s[i];
    }
    i := i + 1;
  }
}
