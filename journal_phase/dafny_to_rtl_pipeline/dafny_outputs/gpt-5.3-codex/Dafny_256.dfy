module ContainsSequence {

  method ContainsSequence(list: seq<seq<int>>, sub: seq<int>) returns (result: bool)
    ensures result <==> (exists i :: 0 <= i < |list| && list[i] == sub)
  {
    result := false;
    var i := 0;

    while i < |list|
      invariant 0 <= i <= |list|
      invariant result <==> (exists k :: 0 <= k < i && list[k] == sub)
      decreases |list| - i
    {
      if list[i] == sub {
        result := true;
      }
      i := i + 1;
    }
  }

}
