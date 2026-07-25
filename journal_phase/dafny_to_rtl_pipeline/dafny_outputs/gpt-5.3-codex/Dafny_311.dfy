method AnalyzeArray(a: array<int>) returns (sum: int, minVal: int, maxVal: int, hasNegative: bool)
  requires a.Length > 0
  ensures sum == SumSpec(a)
  ensures minVal == MinSpec(a)
  ensures maxVal == MaxSpec(a)
  ensures hasNegative <==> ExistsNegative(a)
{
  var i := 0;
  sum := 0;
  minVal := a[0];
  maxVal := a[0];
  hasNegative := false;

  while i < a.Length
    invariant 0 <= i <= a.Length
    invariant sum == SumPrefix(a, i)
    invariant (i == 0 ==> minVal == a[0]) && (i > 0 ==> minVal == MinPrefix(a, i))
    invariant (i == 0 ==> maxVal == a[0]) && (i > 0 ==> maxVal == MaxPrefix(a, i))
    invariant hasNegative <==> ExistsNegativePrefix(a, i)
    decreases a.Length - i
  {
    assert 0 <= i < a.Length;

    sum := sum + a[i];
    assert sum == SumPrefix(a, i + 1);

    if i == 0 {
      minVal := a[i];
      maxVal := a[i];
      assert minVal == MinPrefix(a, i + 1);
      assert maxVal == MaxPrefix(a, i + 1);
    } else {
      if a[i] < minVal {
        minVal := a[i];
      }
      if a[i] > maxVal {
        maxVal := a[i];
      }
      assert minVal == MinPrefix(a, i + 1);
      assert maxVal == MaxPrefix(a, i + 1);
    }

    if a[i] < 0 {
      hasNegative := true;
    }
    assert hasNegative <==> ExistsNegativePrefix(a, i + 1);

    i := i + 1;
  }

  assert i == a.Length;
  assert SumPrefix(a, a.Length) == SumSpec(a);
  assert MinPrefix(a, a.Length) == MinSpec(a);
  assert MaxPrefix(a, a.Length) == MaxSpec(a);
  assert ExistsNegativePrefix(a, a.Length) == ExistsNegative(a);
}

function SumSpec(a: array<int>): int
  reads a
{
  SumPrefix(a, a.Length)
}

function MinSpec(a: array<int>): int
  requires a.Length > 0
  reads a
{
  MinPrefix(a, a.Length)
}

function MaxSpec(a: array<int>): int
  requires a.Length > 0
  reads a
{
  MaxPrefix(a, a.Length)
}

function ExistsNegative(a: array<int>): bool
  reads a
{
  ExistsNegativePrefix(a, a.Length)
}

function SumPrefix(a: array<int>, n: nat): int
  requires n <= a.Length
  reads a
  decreases n
{
  if n == 0 then 0 else SumPrefix(a, n - 1) + a[n - 1]
}

function MinPrefix(a: array<int>, n: nat): int
  requires a.Length > 0
  requires n <= a.Length
  reads a
  decreases n
{
  if n == 0 then a[0]
  else if n == 1 then a[0]
  else
    var prev := MinPrefix(a, n - 1);
    if a[n - 1] < prev then a[n - 1] else prev
}

function MaxPrefix(a: array<int>, n: nat): int
  requires a.Length > 0
  requires n <= a.Length
  reads a
  decreases n
{
  if n == 0 then a[0]
  else if n == 1 then a[0]
  else
    var prev := MaxPrefix(a, n - 1);
    if a[n - 1] > prev then a[n - 1] else prev
}

function ExistsNegativePrefix(a: array<int>, n: nat): bool
  requires n <= a.Length
  reads a
  decreases n
{
  if n == 0 then false else ExistsNegativePrefix(a, n - 1) || a[n - 1] < 0
}
