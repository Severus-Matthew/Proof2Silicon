class A {
  var value: int

  constructor ()
    ensures value == 10
  {
    value := 10;
  }
}

class B {
  var a: A

  constructor ()
    ensures a != null
    ensures a.value == 10
  {
    a := new A();
  }

  method m()
    requires a != null
    requires a.value == 10
    modifies a
    ensures a.value == 10
  {
    assert a.value == 10;
    a.value := 20;
    assert a.value == 20;
    a.value := 10;
    assert a.value == 10;

    a.value := 20;
    assert a.value == 20;
    a.value := 10;
    assert a.value == 10;
  }
}
