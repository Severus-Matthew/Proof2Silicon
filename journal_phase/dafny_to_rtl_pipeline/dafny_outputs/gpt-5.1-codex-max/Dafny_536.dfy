module M0 {
  class Container {
    var s: set<int>;

    constructor ()
      ensures s == {}
    {
      s := {};
    }

    method Add(x: int)
      modifies this
      ensures s == old(s) + {x}
    {
      s := s + {x};
    }

    method Remove(x: int)
      modifies this
      ensures s == old(s) - {x}
    {
      s := s - {x};
    }

    method Contains(x: int) returns (b: bool)
      ensures b == (x in s)
    {
      b := x in s;
    }
  }

  method Demo(x: int) returns (result: bool)
    ensures result
  {
    var p := new Container();
    p.Add(x);
    var c := p.Contains(x);
    assert c;
    p.Remove(x);
    var c2 := p.Contains(x);
    assert !c2;
    p.Add(x);
    var c3 := p.Contains(x);
    assert c3;
    result := c3;
  }
}

module M1 {
  import opened M0

  method Demo(x: int) returns (result: bool)
    ensures result
  {
    var p := new Container();
    p.Add(x);
    var c := p.Contains(x);
    assert c;
    p.Remove(x);
    var c2 := p.Contains(x);
    assert !c2;
    result := c;
  }
}

module M2 {
  import opened M0

  method Demo(x: int) returns (result: bool)
    ensures result
  {
    var p := new Container();
    p.Add(x);
    var c := p.Contains(x);
    assert c;
    p.Remove(x);
    var c2 := p.Contains(x);
    assert !c2;
    p.Add(x);
    var c3 := p.Contains(x);
    assert c3;
    result := c3;
  }
}
