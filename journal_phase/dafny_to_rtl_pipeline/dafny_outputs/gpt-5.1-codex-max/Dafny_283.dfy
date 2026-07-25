// Specification of factorial using a recursive mathematical function (for reasoning only)
function factorialSpec(n: nat): nat
  decreases n
{
  if n == 0 then 1 else n * factorialSpec(n - 1)
}

// Specification for the volume of a cube
function cubeSpec(size: nat): nat
{
  size * size * size
}

// Iterative computation of factorial (no recursion in executable code)
method IterativeFactorial(n: nat) returns (res: nat)
  requires n >= 0
  ensures res == factorialSpec(n)
{
  var acc: nat := 1;
  var i: nat := 1;

  // The loop maintains that 'acc' equals the factorial of numbers up to i-1.
  while i <= n
    invariant 1 <= i && i <= n + 1
    invariant acc == factorialSpec(i - 1)
    decreases n - i + 1
  {
    // Multiply by the current factor
    acc := acc * i;

    // By the definition of factorialSpec for i > 0,
    // factorialSpec(i) == i * factorialSpec(i - 1).
    assert i > 0;
    assert acc == factorialSpec(i);

    // Move to the next factor
    i := i + 1;

    // Re-establish the invariant with the updated i
    assert acc == factorialSpec(i - 1);
  }

  // At loop exit, i == n + 1, so acc == factorialSpec(n)
  res := acc;
  assert res == factorialSpec(n);
}

// Iterative computation of a cube's volume (size^3) without recursion
method CubeVolume(size: nat) returns (volume: nat)
  requires size > 0 // precondition: size must be positive
  ensures volume == cubeSpec(size) // postcondition: volume equals size cubed
{
  volume := 0;
  var i: nat := 1;

  // The loop maintains that 'volume' equals (i-1) * size^2.
  while i <= size
    invariant 1 <= i && i <= size + 1
    invariant volume == (i - 1) * size * size
    decreases size - i + 1
  {
    volume := volume + size * size; // add one layer of size^2
    i := i + 1;
    // Re-establish the invariant
    assert volume == (i - 1) * size * size;
  }

  // At loop exit, i == size + 1, so volume == size * size * size
  assert volume == size * size * size;
}

// Simple tests
method Main()
{
  var f0 := IterativeFactorial(0);
  assert f0 == 1;

  var f5 := IterativeFactorial(5);
  assert f5 == 120;

  var f7 := IterativeFactorial(7);
  assert f7 == 5040;

  var c2 := CubeVolume(2);
  assert c2 == 8;

  var c3 := CubeVolume(3);
  assert c3 == 27;
}
