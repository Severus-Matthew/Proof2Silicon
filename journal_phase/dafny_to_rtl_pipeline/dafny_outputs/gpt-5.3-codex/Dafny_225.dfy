module SumReasoning {

  // Logical summation over [0..n]
  function Sum(f: nat -> int, n: nat): int
    decreases n
  {
    if n == 0 then f(0) else Sum(f, n - 1) + f(n)
  }

  // Alias used by some proofs/specs
  function SumPrefix(f: nat -> int, n: nat): int
    decreases n
  {
    if n == 0 then f(0) else SumPrefix(f, n - 1) + f(n)
  }

  lemma SumEqualsPrefix(f: nat -> int, n: nat)
    ensures Sum(f, n) == SumPrefix(f, n)
    decreases n
  {
    if n == 0 {
    } else {
      SumEqualsPrefix(f, n - 1);
    }
  }

  lemma SumIsCommute(f: nat -> int, g: nat -> int, n: nat)
    requires forall k: nat :: k <= n ==> f(k) == g(k)
    ensures Sum(f, n) == Sum(g, n)
    decreases n
  {
    if n == 0 {
      assert f(0) == g(0);
    } else {
      SumIsCommute(f, g, n - 1);
      assert f(n) == g(n);
      assert Sum(f, n) == Sum(f, n - 1) + f(n);
      assert Sum(g, n) == Sum(g, n - 1) + g(n);
    }
  }

  lemma SumIsDistributive(f: nat -> int, g: nat -> int, n: nat)
    ensures Sum((k: nat) => f(k) + g(k), n) == Sum(f, n) + Sum(g, n)
    decreases n
  {
    if n == 0 {
    } else {
      SumIsDistributive(f, g, n - 1);
      assert Sum((k: nat) => f(k) + g(k), n) ==
             Sum((k: nat) => f(k) + g(k), n - 1) + (f(n) + g(n));
      assert Sum(f, n) == Sum(f, n - 1) + f(n);
      assert Sum(g, n) == Sum(g, n - 1) + g(n);
    }
  }

  lemma SumIsNested(h1: int -> int, h2: int -> int, f: nat -> int, n: nat)
    requires forall x: int :: h1(x) == h2(x)
    ensures Sum((k: nat) => h1(f(k)), n) == Sum((k: nat) => h2(f(k)), n)
    decreases n
  {
    if n == 0 {
      assert h1(f(0)) == h2(f(0));
    } else {
      SumIsNested(h1, h2, f, n - 1);
      assert h1(f(n)) == h2(f(n));
      assert Sum((k: nat) => h1(f(k)), n) ==
             Sum((k: nat) => h1(f(k)), n - 1) + h1(f(n));
      assert Sum((k: nat) => h2(f(k)), n) ==
             Sum((k: nat) => h2(f(k)), n - 1) + h2(f(n));
    }
  }
}
