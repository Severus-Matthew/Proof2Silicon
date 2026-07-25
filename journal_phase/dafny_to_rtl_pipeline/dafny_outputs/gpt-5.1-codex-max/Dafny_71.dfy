module A8Q1 {

  function min3(x: int, y: int, z: int): int
    ensures min3(x, y, z) <= x && min3(x, y, z) <= y && min3(x, y, z) <= z
  {
    if x <= y && x <= z then x
    else if y <= z then y
    else z
  }

  method FindMin(x: int, y: int, z: int) returns (m: int)
    ensures m <= x && m <= y && m <= z
    ensures m == min3(x, y, z)
  {
    if x <= y && x <= z {
      m := x;
    } else if y <= x && y <= z {
      m := y;
    } else {
      m := z;
    }
  }

}
