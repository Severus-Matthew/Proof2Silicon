class MutableMap<K(==), V>
{
  var m: map<K, V>;

  constructor ()
    ensures m == map[]
  {
    m := map[];
  }

  method Add(k: K, v: V)
    requires k !in m
    modifies this
    ensures m == old(m)[k := v]
    ensures k in m && m[k] == v
  {
    m := m[k := v];
  }

  method Remove(k: K)
    requires k in m
    modifies this
    ensures m == old(m) - {k}
    ensures k !in m
  {
    m := m - {k};
  }

  function Get(k: K): V
    requires k in m
    reads this
  {
    m[k]
  }

  function Contains(k: K): bool
    reads this
  {
    k in m
  }

  function Size(): nat
    reads this
  {
    |m|
  }

  function Select(k: K): V
    requires k in m
    reads this
  {
    m[k]
  }

  function Keys(): set<K>
    reads this
  {
    set k: K | k in m
  }

  method Demo()
  {
    var mm := new MutableMap<int, int>();
    assert mm.Size() == 0;

    mm.Add(1, 10);
    mm.Add(2, 20);
    assert mm.Get(1) == 10;
    assert mm.Get(2) == 20;
    assert mm.Size() == 2;

    var val1 := mm.Select(1);
    assert val1 == 10;

    var present := mm.Contains(2);
    assert present;

    var ks := mm.Keys();
    assert 1 in ks && 2 in ks;

    mm.Remove(1);
    assert !mm.Contains(1);
    assert mm.Size() == 1;
  }
}
