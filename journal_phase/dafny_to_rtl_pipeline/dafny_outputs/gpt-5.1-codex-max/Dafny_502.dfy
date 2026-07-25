predicate SortedDesc<T>(s: seq<T>, key: T -> int)
{
  forall i, j :: 0 <= i < j < |s| ==> key(s[j]) < key(s[i])
}

lemma SortedDescExtend<T>(s: seq<T>, x: T, key: T -> int)
  requires SortedDesc(s, key)
  requires forall k :: 0 <= k < |s| ==> key(x) < key(s[k])
  ensures SortedDesc(s + [x], key)
{
  var t := s + [x];
  forall i, j | 0 <= i < j < |t|
    ensures key(t[j]) < key(t[i])
  {
    if j < |s| {
      assert key(t[j]) == key(s[j]);
      assert key(t[i]) == key(s[i]);
      assert key(s[j]) < key(s[i]);
    } else {
      assert j == |s|;
      assert key(t[j]) == key(x);
      assert key(t[i]) == key(s[i]);
      assert key(x) < key(s[i]);
    }
  }
}

method SwapPreservesDistinct<T>(a: array<T>, i: int, j: int, key: T -> int)
  requires a != null
  requires 0 <= i < a.Length
  requires 0 <= j < a.Length
  requires forall p, q :: 0 <= p < q < a.Length ==> key(a[p]) != key(a[q])
  modifies a
  ensures forall p, q :: 0 <= p < q < a.Length ==> key(a[p]) != key(a[q])
  ensures a[i] == old(a[j]) && a[j] == old(a[i])
  ensures forall k :: 0 <= k < a.Length && k != i && k != j ==> a[k] == old(a[k])
{
  ghost var before := a[..];
  var tmp := a[i];
  a[i] := a[j];
  a[j] := tmp;

  assert a[i] == before[j];
  assert a[j] == before[i];
  assert forall k :: 0 <= k < a.Length && k != i && k != j ==> a[k] == before[k];

  forall p, q | 0 <= p < q < a.Length
    ensures key(a[p]) != key(a[q])
  {
    if p == i && q == j {
      assert key(a[p]) == key(before[j]);
      assert key(a[q]) == key(before[i]);
      assert key(before[j]) != key(before[i]);
    } else if p == i && q != j {
      assert key(a[p]) == key(before[j]);
      if q != i && q != j {
        assert a[q] == before[q];
      }
      assert key(before[j]) != key(before[q]);
    } else if p == j && q != i {
      assert key(a[p]) == key(before[i]);
      if q != i && q != j {
        assert a[q] == before[q];
      }
      assert key(before[i]) != key(before[q]);
    } else if q == i && p != j {
      assert key(a[q]) == key(before[j]);
      if p != i && p != j {
        assert a[p] == before[p];
      }
      assert key(before[p]) != key(before[j]);
    } else if q == j && p != i {
      assert key(a[q]) == key(before[i]);
      if p != i && p != j {
        assert a[p] == before[p];
      }
      assert key(before[p]) != key(before[i]);
    } else {
      if p != i && p != j {
        assert a[p] == before[p];
      }
      if q != i && q != j {
        assert a[q] == before[q];
      }
      assert key(before[p]) != key(before[q]);
    }
  }
}

method GenericSort<T>(a: array<T>, less: (int, int) -> bool, key: T -> int)
  requires a != null
  requires forall x, y :: less(x, y) <==> x < y
  requires forall p, q :: 0 <= p < q < a.Length ==> key(a[p]) != key(a[q])
  modifies a
  ensures forall i, j :: 0 <= i < j < a.Length ==> less(key(a[j]), key(a[i]))
  ensures forall i, j :: 0 <= i < j < a.Length ==> key(a[j]) < key(a[i])
{
  var n := a.Length;
  var i := 0;
  while i < n
    invariant 0 <= i <= n
    invariant SortedDesc(a[..i], key)
    invariant forall p, q :: 0 <= p < i <= q < n ==> key(a[p]) > key(a[q])
    invariant forall p, q :: 0 <= p < q < n ==> key(a[p]) != key(a[q])
    decreases n - i
  {
    var maxIndex := i;
    var maxKey := key(a[i]);
    var j := i + 1;
    while j < n
      invariant i + 1 <= j <= n
      invariant i <= maxIndex < j
      invariant maxKey == key(a[maxIndex])
      invariant forall k :: i <= k < j ==> key(a[k]) <= maxKey
      invariant forall k :: i <= k < j ==> k != maxIndex ==> key(a[k]) < maxKey
      invariant SortedDesc(a[..i], key)
      invariant forall p, q :: 0 <= p < i <= q < n ==> key(a[p]) > key(a[q])
      invariant forall p, q :: 0 <= p < q < n ==> key(a[p]) != key(a[q])
      decreases n - j
    {
      if key(a[j]) > maxKey {
        maxIndex := j;
        maxKey := key(a[j]);
      }
      j := j + 1;
    }

    ghost var before := a[..];

    SwapPreservesDistinct(a, i, maxIndex, key);

    assert a[i] == before[maxIndex];
    assert key(a[i]) == maxKey;

    assert forall p :: 0 <= p < i ==> key(a[p]) > key(a[i]) by
    {
      var p: int;
      assume 0 <= p < i;
      assert key(a[p]) == key(before[p]);
      assert key(a[i]) == key(before[maxIndex]);
      assert key(before[p]) > key(before[maxIndex]);
    }

    assert forall k :: i + 1 <= k < n ==> key(a[k]) < key(a[i]) by
    {
      var k: int;
      assume i + 1 <= k < n;
      if maxIndex == i {
        assert a[k] == before[k];
        assert key(before[k]) < maxKey;
        assert key(a[k]) == key(before[k]);
        assert key(a[i]) == maxKey;
      } else if k == maxIndex {
        assert a[k] == before[i];
        assert key(before[i]) < maxKey;
        assert key(a[i]) == maxKey;
      } else {
        assert a[k] == before[k];
        assert key(before[k]) < maxKey;
        assert key(a[i]) == maxKey;
      }
    }

    SortedDescExtend(a[..i], a[i], key);
    assert SortedDesc(a[..i + 1], key);

    assert forall p, q :: 0 <= p < i + 1 <= q < n ==> key(a[p]) > key(a[q]) by
    {
      var p: int;
      var q: int;
      assume 0 <= p < i + 1 <= q < n;
      if p < i {
        assert key(a[p]) == key(before[p]);
        if maxIndex == i {
          assert a[q] == before[q];
          assert key(before[p]) > key(before[q]);
        } else if q == maxIndex {
          assert a[q] == before[i];
          assert key(before[p]) > key(before[i]);
        } else {
          assert a[q] == before[q];
          assert key(before[p]) > key(before[q]);
        }
      } else {
        assert p == i;
        assert key(a[p]) == key(before[maxIndex]);
        if maxIndex == i {
          assert a[q] == before[q];
          assert key(before[q]) < key(before[maxIndex]);
        } else if q == maxIndex {
          assert a[q] == before[i];
          assert key(before[i]) < key(before[maxIndex]);
        } else {
          assert a[q] == before[q];
          assert key(before[q]) < key(before[maxIndex]);
        }
      }
      assert key(a[p]) > key(a[q]);
    }

    i := i + 1;
  }
}

method ArrayMap<T>(a: array<T>, f: T -> T)
  requires a != null
  modifies a
  ensures forall i :: 0 <= i < a.Length ==> a[i] == f(old(a[i]))
{
  ghost var before := a[..];
  var i := 0;
  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant forall k :: 0 <= k < i ==> a[k] == f(before[k])
    invariant forall k :: i <= k < a.Length ==> a[k] == before[k]
    decreases a.Length - i
  {
    a[i] := f(a[i]);
    i := i + 1;
  }
}
