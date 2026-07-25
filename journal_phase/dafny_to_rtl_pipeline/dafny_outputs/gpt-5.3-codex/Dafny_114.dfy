module MaxModule {

  method Max2(a: int, b: int) returns (c: int)
    ensures c >= a && c >= b
    ensures c == a || c == b
    ensures (a >= b ==> c == a) && (b >= a ==> c == b)
  {
    if a > b {
      c := a;
    } else {
      c := b;
    }
  }

  method Testing(x: int, y: int, z: int) returns (m: int)
    requires x == 10 && y == 20 && z == 5
    ensures m >= x && m >= y && m >= z
    ensures m == x || m == y || m == z
    ensures m == 20
  {
    var arr := new int[3];
    arr[0] := x;
    arr[1] := y;
    arr[2] := z;

    assert arr[0] == 10 && arr[1] == 20 && arr[2] == 5;

    var m01 := Max2(arr[0], arr[1]);
    assert m01 >= arr[0] && m01 >= arr[1];
    assert m01 == arr[0] || m01 == arr[1];

    m := Max2(m01, arr[2]);
    assert m >= m01 && m >= arr[2];
    assert m >= arr[0] && m >= arr[1] && m >= arr[2];
    assert m == arr[0] || m == arr[1] || m == arr[2];

    assert m == 20;
  }

  method Main()
    ensures true
  {
    var x := 10;
    var y := 20;
    var z := 5;

    var m := Testing(x, y, z);
    assert m == 20;
  }
}
