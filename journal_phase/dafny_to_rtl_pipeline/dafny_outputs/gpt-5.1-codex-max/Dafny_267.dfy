class Program {
  static method Max(arr: array<int>) returns (m: int)
    requires arr != null && arr.Length > 0
    ensures forall i :: 0 <= i < arr.Length ==> arr[i] <= m
    ensures exists i :: 0 <= i < arr.Length && arr[i] == m
  {
    m := arr[0];
    var i := 1;
    while i < arr.Length
      invariant 1 <= i <= arr.Length
      invariant forall j :: 0 <= j < i ==> arr[j] <= m
      invariant exists j :: 0 <= j < i && arr[j] == m
      decreases arr.Length - i
    {
      if arr[i] > m {
        m := arr[i];
      }
      i := i + 1;
    }
  }

  static method Main() {
    var a := new int[15];
    a[0] := 0;
    a[1] := 2;
    a[2] := 1;
    a[3] := 2;
    a[4] := 3;
    a[5] := 4;
    a[6] := 5;
    a[7] := 6;
    a[8] := 7;
    a[9] := 8;
    a[10] := 9;
    a[11] := 10;
    a[12] := 11;
    a[13] := 12;
    a[14] := 13;
    var mx := Max(a);
    assert mx == 13;
  }
}
