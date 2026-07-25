method Main()
{
  // Use a while loop to iterate through an array and compute its sum.
  // In this Dafny code, the while loop provides a step-by-step traversal with
  // loop invariants that help prove safety and correctness.
  var a := new int[5];
  a[0], a[1], a[2], a[3], a[4] := 1, 2, 3, 4, 5;

  var i := 0;
  var sum := 0;

  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant sum == (if i == 0 then 0
                      else if i == 1 then a[0]
                      else if i == 2 then a[0] + a[1]
                      else if i == 3 then a[0] + a[1] + a[2]
                      else if i == 4 then a[0] + a[1] + a[2] + a[3]
                      else a[0] + a[1] + a[2] + a[3] + a[4])
    decreases a.Length - i
  {
    sum := sum + a[i];
    i := i + 1;
  }

  assert sum == 15;
}
