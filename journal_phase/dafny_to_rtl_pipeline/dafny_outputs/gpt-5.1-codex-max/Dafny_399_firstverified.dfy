module PowerLogs {
  // Mathematical exponentiation for specifications
  function pow(base: nat, exp: nat): nat
    decreases exp
  {
    if exp == 0 then 1 else base * pow(base, exp - 1)
  }

  // Compute base^exp iteratively (no recursion)
  method power(base: nat, exp: nat) returns (res: nat)
    ensures res == pow(base, exp)
  {
    var i: nat := 0;
    res := 1;
    while i < exp
      invariant i <= exp
      invariant res == pow(base, i)
      decreases exp - i
    {
      res := res * base;
      i := i + 1;
    }
  }

  // Compute ⌊log2(n)⌋ iteratively
  method log_floor(n: nat) returns (lf: nat)
    requires n > 0
    ensures pow(2, lf) <= n < pow(2, lf + 1)
  {
    var currentPow: nat := 1;
    lf := 0;
    while currentPow * 2 <= n
      invariant currentPow == pow(2, lf)
      invariant currentPow <= n
      decreases n - currentPow
    {
      currentPow := currentPow * 2;
      lf := lf + 1;
    }
    assert currentPow == pow(2, lf);
    assert currentPow * 2 > n;
    assert pow(2, lf + 1) == pow(2, lf) * 2;
    assert pow(2, lf) <= n;
    assert n < pow(2, lf + 1);
  }

  // Compute ⌊log2(⌊log2(n)⌋)⌋ iteratively
  method log_floor_floor(n: nat) returns (res: nat)
    requires n > 0
    ensures res >= 0
  {
    var lf := log_floor(n);
    if lf > 0 {
      res := log_floor(lf);
    } else {
      res := 0;
    }
  }

  // Compute ⌊log2(n/d)⌋ iteratively
  method log_floor_div(n: nat, d: nat) returns (res: nat)
    requires d > 0
    requires n >= d
    ensures pow(2, res) <= n / d < pow(2, res + 1)
  {
    var q := n / d;
    res := log_floor(q);
  }

  // Compute ⌊log2(⌊log2(n/d)⌋)⌋ iteratively
  method log_floor_div_floor(n: nat, d: nat) returns (res: nat)
    requires d > 0
    requires n >= d
    ensures res >= 0
  {
    var q := n / d;
    var lf := log_floor(q);
    if lf > 0 {
      res := log_floor(lf);
    } else {
      res := 0;
    }
  }
}
