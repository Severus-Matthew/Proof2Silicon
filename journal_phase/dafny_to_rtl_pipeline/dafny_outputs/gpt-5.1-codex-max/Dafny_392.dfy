lemma SquareGeSelf(j: nat)
  requires j > 0
  ensures j * j >= j
{
  // j*j - j == j*(j-1), which is non-negative for j>0
  assert j * j - j == j * (j - 1);
  assert j - 1 >= 0;
  assert j * (j - 1) >= 0;
}

lemma SquareAbove(n: nat, j: nat)
  requires j > n
  ensures j * j > n
{
  SquareGeSelf(j);
  // From j > n, we have j >= n + 1
  assert j >= n + 1;
  assert j * j >= j;
  assert j * j >= n + 1;
  assert j * j > n;
}

method IsPerfectSquare(n: nat) returns (result: bool)
  ensures result ==> (exists i: nat :: i * i == n)
  ensures !result ==> (forall i: nat :: i * i != n)
{
  var i: nat := 0;
  while i <= n
    invariant 0 <= i <= n + 1
    invariant forall j: nat :: j < i ==> j * j != n
    decreases n - i + 1
  {
    if i * i == n {
      result := true;
      assert exists k: nat :: k * k == n;
      return;
    }
    i := i + 1;
  }
  // Loop exited with i > n and i <= n + 1, so i == n + 1
  assert i == n + 1;
  result := false;

  // Show no square equals n
  forall j: nat | true
    ensures j * j != n
  {
    if j < i {
      // Covered by loop invariant
      assert j * j != n;
    } else {
      // j >= i = n + 1 implies j > n, so j*j > n
      assert j >= i;
      assert j > n;
      SquareAbove(n, j);
      assert j * j != n;
    }
  }
}
