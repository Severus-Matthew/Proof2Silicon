module FactorialModule {

  // Ghost specification of factorial, used only for reasoning.
  function factorialSpec(n: nat): nat
    decreases n
  {
    if n == 0 then 1 else n * factorialSpec(n - 1)
  }

  // Iterative factorial implementation (no recursion in executable code).
  method FactorialIterative(n: nat) returns (res: nat)
    ensures res == factorialSpec(n)
  {
    var product: nat := 1;
    var i: nat := 1;

    while i <= n
      invariant 1 <= i <= n + 1
      invariant product == factorialSpec(i - 1)
      decreases n - i + 1
    {
      // Multiply the accumulated product by i
      product := product * i;
      // Increment i
      i := i + 1;
      // The loop invariant still holds: product == factorialSpec(i - 1)
      assert product == factorialSpec(i - 1);
    }

    // After the loop, i == n + 1 and product == factorialSpec(n)
    res := product;
    assert res == factorialSpec(n);
  }

  // A method to test the factorial function iteratively.
  method TestFactorial(n: nat) returns (res: nat)
    ensures res == factorialSpec(n)
  {
    var product: nat := 1;
    var i: nat := 1;

    while i <= n
      invariant 1 <= i <= n + 1
      invariant product == factorialSpec(i - 1)
      decreases n - i + 1
    {
      product := product * i;
      i := i + 1;
    }

    res := product;
  }

  // Simple demonstrations
  method Demo() {
    var r0 := FactorialIterative(0);
    assert r0 == 1;

    var r1 := FactorialIterative(1);
    assert r1 == 1;

    var r5 := FactorialIterative(5);
    assert r5 == 120;

    var r3 := TestFactorial(3);
    assert r3 == 6;
  }
}
