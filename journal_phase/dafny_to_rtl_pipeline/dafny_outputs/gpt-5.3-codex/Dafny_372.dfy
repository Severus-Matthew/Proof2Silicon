module AllCharactersSame {

  method CheckAllCharactersSame(s: string) returns (r: bool)
    requires |s| > 0
    ensures r <==> (forall i :: 0 <= i < |s| ==> s[i] == s[0])
  {
    var i: int := 1;
    r := true;

    while i < |s|
      invariant 1 <= i <= |s|
      invariant r ==> (forall j :: 0 <= j < i ==> s[j] == s[0])
      invariant !r ==> (exists j :: 0 <= j < i && s[j] != s[0])
      decreases |s| - i
    {
      if s[i] != s[0] {
        r := false;
      }
      i := i + 1;
    }
  }
}
