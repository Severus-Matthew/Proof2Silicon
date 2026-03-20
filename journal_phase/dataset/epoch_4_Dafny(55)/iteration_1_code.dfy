method Test() {
  var s := [1, 2, 3, 4];
  var arr := ToArray(s);
  // arr is now a fresh array containing [1, 2, 3, 4]
  assert arr[0] == 1 && arr[1] == 2 && arr[2] == 3 && arr[3] == 4;
}