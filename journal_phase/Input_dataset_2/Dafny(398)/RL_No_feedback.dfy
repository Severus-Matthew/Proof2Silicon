// Exponential function properties in Dafny - Focus on Positivity

// Exponential function as a ghost function
// Using a recursive definition that's easier to reason about
ghost function Exp(x: real): real
  decreases if x < 0.0 then -x else x
{
  if x == 0.0 then
    1.0
  else if x > 0.0 then
    // For positive x: Exp(x) = Exp(x/2) * Exp(x/2)
    var half := x / 2.0;
    var exp_half := Exp(half);
    exp_half * exp_half
  else
    // For negative x: Exp(x) = 1 / Exp(-x)
    1.0 / Exp(-x)
}

// Lemma for positivity: Exp(x) > 0 for all real x
lemma PositivityLemma(x: real)
  ensures Exp(x) > 0.0
  decreases if x < 0.0 then -x else x
{
  if x == 0.0 {
    // Base case: Exp(0) = 1 > 0
    // Dafny knows that 1.0 > 0.0
  } else if x > 0.0 {
    // For positive x, Exp(x) = Exp(x/2) * Exp(x/2)
    // By induction, Exp(x/2) > 0, so product > 0
    var half := x / 2.0;
    PositivityLemma(half);
    // Product of positive numbers is positive
    // Dafny's arithmetic axioms handle this
  } else {
    // For negative x, Exp(x) = 1/Exp(-x)
    // By induction, Exp(-x) > 0, so reciprocal > 0
    var neg_x := -x;
    PositivityLemma(neg_x);
    // Reciprocal of positive number is positive
    // Dafny knows this property
  }
}

// Main theorem: Exponential function is always positive
theorem ExponentialPositivity(x: real)
  ensures Exp(x) > 0.0
  ensures Exp(0.0) == 1.0
{
  // Prove positivity using the lemma
  PositivityLemma(x);
  
  // Prove Exp(0) = 1 (follows directly from definition)
  // This is already in the ensures clause, and Dafny can verify it
}

// Additional lemma to show the function is well-defined
lemma ExpWellDefined(x: real)
  ensures Exp(x) > 0.0
  ensures x == 0.0 ==> Exp(x) == 1.0
  ensures x > 0.0 ==> Exp(x) == Exp(x / 2.0) * Exp(x / 2.0)
  ensures x < 0.0 ==> Exp(x) == 1.0 / Exp(-x)
{
  // All these properties follow from the function definition
  // and the PositivityLemma
  PositivityLemma(x);
}

// To extend the verification to more general cases, we can add a wrapper function
// that specifically checks for non-positive inputs
// and ensures that the exponential function's properties hold in that case
// by returning 0 if the input is non-positive
ghost function PositiveExponential(x: real): real
{
  if x <= 0.0 then
    0.0
  else
    Exp(x)
}

// Test/example usage
method TestExponential()
{
  // Verify properties for test values
  
  // Test at x = 0
  var test_x: real := 0.0;
  ExponentialPositivity(test_x);
  assert Exp(test_x) == 1.0;
  
  // Test for a negative value
  var negative_x: real := -1.0;
  ExponentialPositivity(negative_x);
  assert Exp(negative_x) > 0.0;
  
  // Test for a positive value
  var positive_x: real := 2.0;
  ExponentialPositivity(positive_x);
  assert Exp(positive_x) > 0.0;
  
  // Test PositiveExponential function
  assert PositiveExponential(0.0) == 0.0;
  assert PositiveExponential(-1.0) == 0.0;
  // For positive values, PositiveExponential should return Exp(x)
  assert PositiveExponential(2.0) == Exp(2.0);
  
  // Additional test cases for better coverage
  var x1: real := 1.0;
  ExponentialPositivity(x1);
  assert Exp(x1) > 0.0;
  
  var x2: real := -2.5;
  ExponentialPositivity(x2);
  assert Exp(x2) > 0.0;
  
  // Test the recursive property for positive x
  var x3: real := 4.0;
  ExponentialPositivity(x3);
  assert Exp(x3) == Exp(x3 / 2.0) * Exp(x3 / 2.0);
  
  // Test the reciprocal property for negative x
  var x4: real := -3.0;
  ExponentialPositivity(x4);
  assert Exp(x4) == 1.0 / Exp(-x4);
}