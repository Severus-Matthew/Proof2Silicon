method RemoveElement(s: array<int>, k: int) returns (v: array<int>)
  requires s != null
  requires 0 <= k < s.Length
  ensures v != null
  ensures v.Length == s.Length - 1
  ensures forall i :: 0 <= i < k ==> v[i] == s[i]
  ensures forall i :: k <= i < v.Length ==> v[i] == s[i + 1]
{
  v := new int[s.Length - 1];

  var i := 0;
  while i < v.Length
    invariant 0 <= i <= v.Length
    invariant v.Length == s.Length - 1
    invariant forall j :: 0 <= j < i && j < k ==> v[j] == s[j]
    invariant forall j :: 0 <= j < i && k <= j < v.Length ==> v[j] == s[j + 1]
    decreases v.Length - i
  {
    if i < k {
      v[i] := s[i];
    } else {
      v[i] := s[i + 1];
    }
    i := i + 1;
  }
}
