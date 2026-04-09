function power(r: real, n: nat): real
  ensures power(r, 0) == 1.0
  ensures n > 0 ==> power(r, n) == r * power(r, n-1)
{
  if n == 0 then 1.0 else r * power(r, n-1)
}

function geometricTerm(n: nat, a: real, r: real): real
  requires n > 0
  ensures geometricTerm(n, a, r) == a * power(r, n-1)
{
  a * power(r, n-1)
}

function sumGeometricTerms(n: nat, a: real, r: real): real
  requires n > 0
  ensures sumGeometricTerms(n, a, r) == (
    if n == 1 then geometricTerm(1, a, r)
    else sumGeometricTerms(n-1, a, r) + geometricTerm(n, a, r)
  )
{
  if n == 1 then
    geometricTerm(1, a, r)
  else
    sumGeometricTerms(n-1, a, r) + geometricTerm(n, a, r)
}

function geometricSum(n: nat, a: real, r: real): real
  requires n > 0
  ensures geometricSum(n, a, r) == sumGeometricTerms(n, a, r)
  ensures geometricSum(n, a, r) == 
    if r == 1.0 then 
      n as real * a 
    else 
      a * (1.0 - power(r, n)) / (1.0 - r)
{
  if r == 1.0 then
    n as real * a
  else
    a * (1.0 - power(r, n)) / (1.0 - r)
}

function geometricTermOrSum(n: nat, a: real, r: real): real
  requires n > 0
  ensures geometricTermOrSum(n, a, r) == 
    if n == 1 then a
    else if r == 1.0 then n as real * a
    else a * (1.0 - power(r, n)) / (1.0 - r)
{
  if n == 1 then
    a
  else if r == 1.0 then
    n as real * a
  else
    a * (1.0 - power(r, n)) / (1.0 - r)
}

method Main() {
  // Test cases
  var term3: real := geometricTermOrSum(3, 1.0, 2.0);
  var sum2: real := geometricTermOrSum(2, 2.0, 1.5);
  
  print "3rd term with a=1, r=2: ", term3, "\n";
  print "Sum of first 2 terms with a=2, r=1.5: ", sum2, "\n";
  
  // Additional test: 20th term calculation
  var term20: real := geometricTerm(20, 5.0, 2.0);
  print "20th term with a=5, r=2: ", term20, "\n";
  
  // Sum of first 10 terms with a=5, r=2
  var sum10: real := geometricTermOrSum(10, 5.0, 2.0);
  print "Sum of first 10 terms with a=5, r=2: ", sum10, "\n";
  
  // Test case for r = 1.0
  var sumR1: real := geometricTermOrSum(5, 3.0, 1.0);
  print "Sum of first 5 terms with a=3, r=1: ", sumR1, "\n";
  
  // Test using geometricSum function
  var sum10_alt: real := geometricSum(10, 5.0, 2.0);
  print "Sum of first 10 terms using geometricSum: ", sum10_alt, "\n";
  
  // Additional verification tests
  var test1: real := geometricTermOrSum(1, 5.0, 2.0);
  print "n=1 term with a=5, r=2: ", test1, "\n";
  
  var test2: real := geometricTermOrSum(4, 2.0, 0.5);
  print "Sum of first 4 terms with a=2, r=0.5: ", test2, "\n";
  
  // Verify that geometricSum equals sumGeometricTerms
  var verify1: real := sumGeometricTerms(3, 1.0, 2.0);
  var verify2: real := geometricSum(3, 1.0, 2.0);
  print "sumGeometricTerms(3, 1, 2): ", verify1, "\n";
  print "geometricSum(3, 1, 2): ", verify2, "\n";
  print "Are they equal? ", if verify1 == verify2 then "Yes" else "No", "\n";
}