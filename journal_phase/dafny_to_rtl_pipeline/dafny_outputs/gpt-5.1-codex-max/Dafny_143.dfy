module AddSmallNumbers {

  /// Ghost function to compute the sum of a sequence of integers
  function sumSeq(s: seq<int>): int
    decreases s
  {
    if |s| == 0 then 0 else s[0] + sumSeq(s[1..])
  }

  /// Lemma: the sum of a sequence of non‑negative elements bounded by m
  lemma SumSeqBound(s: seq<int>, m: int)
    requires forall j :: 0 <= j < |s| ==> 0 <= s[j] <= m
    ensures sumSeq(s) <= m * |s|
    decreases |s|
  {
    if |s| == 0 {
    } else {
      SumSeqBound(s[1..], m);
      assert sumSeq(s) == s[0] + sumSeq(s[1..]);
      assert |s[1..]| == |s| - 1;
      assert sumSeq(s[1..]) <= m * (|s| - 1);
      assert 0 <= s[0] <= m;
      assert sumSeq(s) <= m + m * (|s| - 1);
      assert m + m * (|s| - 1) == m * |s|;
    }
  }

  method AddSmall(max: int, a: array<int>, n: nat) returns (r: int)
    requires 0 <= n <= a.Length
    requires forall i :: 0 <= i < n ==> 0 <= a[i] <= max
    ensures r == sumSeq(a[..n])
    ensures sumSeq(a[..n]) <= max * n
    ensures sumSeq(a[..n]) <= r
    ensures r <= max * n
  {
    SumSeqBound(a[..n], max);
    var i := 0;
    r := 0;
    while i < n
      invariant 0 <= i <= n
      invariant r + sumSeq(a[i..n]) == sumSeq(a[..n])
      invariant sumSeq(a[i..n]) <= max * (n - i)
      invariant r <= max * i
      decreases n - i
    {
      assert sumSeq(a[i..n]) == a[i] + sumSeq(a[i+1..n]);
      r := r + a[i];
      i := i + 1;
      SumSeqBound(a[i..n], max);
    }
  }
}
