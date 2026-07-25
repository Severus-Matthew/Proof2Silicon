class AbsClass {
  method AbsIt(xs: array<int>)
    modifies xs
    ensures xs.Length == old(xs.Length)
    ensures forall i :: 0 <= i < xs.Length ==>
      xs[i] == (if old(xs[i]) < 0 then -old(xs[i]) else old(xs[i]))
  {
    var i := 0;
    while i < xs.Length
      invariant 0 <= i <= xs.Length
      invariant xs.Length == old(xs.Length)
      invariant forall j :: 0 <= j < i ==>
        xs[j] == (if old(xs[j]) < 0 then -old(xs[j]) else old(xs[j]))
      invariant forall j :: i <= j < xs.Length ==> xs[j] == old(xs[j])
      decreases xs.Length - i
    {
      if xs[i] < 0 {
        xs[i] := -xs[i];
      }
      i := i + 1;
    }
  }
}
