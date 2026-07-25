predicate sorted_seg(a: array<int>, l: int, h: int)
  requires 0 <= l <= h <= a.Length
  reads a
{
  forall i :: l <= i < h - 1 ==> a[i] <= a[i + 1]
}

function Segment(a: array<int>, l: int, h: int): seq<int>
  requires 0 <= l <= h <= a.Length
  reads a
{
  a[l .. h]
}

method sort_segment(a: array<int>, l: int, h: int)
  requires 0 <= l <= h <= a.Length
  requires sorted_seg(a, l, h)
  ensures sorted_seg(a, l, h)
  ensures forall idx :: 0 <= idx < a.Length && (idx < l || idx >= h) ==> a[idx] == old(a[idx])
{
  // The segment is already sorted by precondition; no action is needed.
}
