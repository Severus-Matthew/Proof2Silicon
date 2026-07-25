module CountListsModule {

  // Counts the number of sequences in the given sequence of integer sequences.
  method CountLists(lists: seq<seq<int>>) returns (count: nat)
    ensures count == |lists|
    ensures count >= 0
  {
    var c: nat := 0;
    var i: nat := 0;
    while i < |lists|
      invariant 0 <= i <= |lists|
      invariant c == i
      invariant c == |lists[..i]|
      decreases |lists| - i
    {
      c := c + 1;
      i := i + 1;
    }
    count := c;
  }

  // Check function to verify correctness of CountLists.
  method Check() {
    // Example sequence of sequences
    var s: seq<seq<int>> := [[1, 2], [], [3, 4, 5]];
    var cnt := CountLists(s);
    assert cnt == |s|;
    assert cnt >= 0;

    // Check with an empty sequence
    var emptySeq: seq<seq<int>> := [];
    var cntEmpty := CountLists(emptySeq);
    assert cntEmpty == 0;
    assert cntEmpty >= 0;

    // Check with a single element sequence
    var singleElementSeq: seq<seq<int>> := [[1]];
    var cntSingle := CountLists(singleElementSeq);
    assert cntSingle == 1;
    assert cntSingle >= 0;

    // Check with a sequence of sequences
    var multiSeq: seq<seq<int>> := [[1, 2], [3, 4], [5]];
    var cntMulti := CountLists(multiSeq);
    assert cntMulti == 3;
    assert cntMulti >= 0;
  }
}
