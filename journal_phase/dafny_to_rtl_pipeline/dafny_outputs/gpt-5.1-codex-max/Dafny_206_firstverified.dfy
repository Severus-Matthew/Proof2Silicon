module BarrierCheck {

  method CheckBarrier(a: array<int>, p: int) returns (isBarrier: bool)
    requires a != null
    requires 0 <= p <= a.Length
    ensures isBarrier ==
      (p < a.Length &&
       (forall i :: 0 <= i < p ==> a[i] < a[i+1]) &&
       (forall i :: p < i < a.Length ==> a[p] < a[i]))
    ensures isBarrier ==> (a.Length >= 2 ==> a[0] < a[1])
  {
    var incBefore := true;
    if p == a.Length {
      // If p == a.Length, we cannot safely check a[p], so the barrier cannot hold
      incBefore := false;
    } else {
      var i := 0;
      while i < p
        invariant 0 <= i <= p
        invariant incBefore == (forall j :: 0 <= j < i ==> a[j] < a[j+1])
      {
        if !(a[i] < a[i+1]) {
          incBefore := false;
        }
        i := i + 1;
      }
    }

    var lessAfter := true;
    if p < a.Length {
      var k := p + 1;
      while k < a.Length
        invariant p + 1 <= k <= a.Length
        invariant lessAfter == (forall j :: p < j < k ==> a[p] < a[j])
      {
        if !(a[p] < a[k]) {
          lessAfter := false;
        }
        k := k + 1;
      }
    }

    isBarrier := p < a.Length && incBefore && lessAfter;
  }

  method Main()
  {
    var arr := new int[5];
    arr[0] := 1;
    arr[1] := 2;
    arr[2] := 5;
    arr[3] := 10;
    arr[4] := 20;
    var p := 2;

    var check := CheckBarrier(arr, p);
    assert check; // For this array and p, the barrier property holds.
  }
}
