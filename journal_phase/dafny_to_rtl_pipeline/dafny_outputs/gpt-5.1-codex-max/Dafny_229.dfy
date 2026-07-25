module Maximum {

  method Max(s: seq<int>) returns (res: int)
    requires |s| > 0
    ensures exists j :: 0 <= j < |s| && s[j] == res
    ensures forall j :: 0 <= j < |s| ==> res >= s[j]
  {
    var i := 1;
    res := s[0];
    while i < |s|
      invariant 1 <= i <= |s|
      invariant exists j :: 0 <= j < i && s[j] == res
      invariant forall j :: 0 <= j < i ==> res >= s[j]
      decreases |s| - i
    {
      if s[i] > res {
        res := s[i];
      }
      i := i + 1;
    }
  }

  method Main() {
    var s := [5, 1, 9, 2, 9, -3];
    var m := Max(s);
    // Should print 9
    print m;
    print "\n";
  }
}
