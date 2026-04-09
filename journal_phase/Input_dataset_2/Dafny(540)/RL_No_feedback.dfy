// Dafny program to find the smallest positive integer that,
// when added to 100, becomes a perfect square

module Main {
  // Predicate to check if a number is a perfect square
  predicate isPerfectSquare(n: int)
    requires n >= 0
  {
    exists k: int :: k >= 0 && k * k == n
  }

  // Coinductive predicate to check that all numbers in a stream
  // are NOT solutions (used to prove our solution is minimal)
  greatest predicate AllNotSolutions(s: Stream<int>, target: int)
  {
    !isPerfectSquare(target + s.head) && AllNotSolutions(s.tail, target)
  }

  // Stream datatype for coinductive reasoning
  codatatype Stream<T> = Cons(head: T, tail: Stream<T>)

  // Function to generate natural numbers starting from n
  function From(n: int): Stream<int>
  {
    Cons(n, From(n + 1))
  }

  // Function to find the smallest solution
  function findSmallestSolution(target: int): (solution: int)
    requires target >= 0
    ensures isPerfectSquare(target + solution)
    ensures forall x: int :: 0 <= x < solution ==> !isPerfectSquare(target + x)
  {
    var i := 0;
    while !isPerfectSquare(target + i)
      invariant forall x: int :: 0 <= x < i ==> !isPerfectSquare(target + x)
      decreases  // Dafny will find a termination measure
    {
      i := i + 1;
    }
    i
  }

  // Coinductive lemma to prove that numbers before our solution
  // are not valid solutions
  greatest lemma ProveMinimality(target: int, solution: int)
    requires target >= 0
    requires solution >= 0
    requires isPerfectSquare(target + solution)
    ensures AllNotSolutions(From(0), target) || 
            (exists k: int :: 0 <= k < solution && isPerfectSquare(target + k))
  {
    if solution == 0 {
      // Base case: if solution is 0, check if target itself is perfect square
    } else {
      // Recursive case: prove that solution-1 is not a valid solution
      var prevStream := From(0);
      if !isPerfectSquare(target + (solution - 1)) {
        // Continue proving for smaller numbers
        ProveMinimality(target, solution - 1);
      }
    }
  }

  // Main method to compute and verify the solution
  method Main() {
    var target := 100;
    var solution := findSmallestSolution(target);
    
    // Verify the solution
    assert isPerfectSquare(target + solution);
    
    // Check that it's indeed the smallest
    assert forall x: int :: 0 <= x < solution ==> !isPerfectSquare(target + x);
    
    // Print the result
    print "Target: ", target, "\n";
    print "Smallest number to add: ", solution, "\n";
    print "Result: ", target + solution, "\n";
    print "Square root: ";
    
    // Find and print the square root
    var k := 0;
    while (k + 1) * (k + 1) <= target + solution {
      k := k + 1;
    }
    print k, " (since ", k, " * ", k, " = ", k * k, ")\n";
    
    // Verify some properties
    assert target + solution == 121;  // 100 + 21 = 121
    assert solution == 21;            // The smallest solution
    assert !isPerfectSquare(100 + 20); // Check that 20 is not a solution
    assert isPerfectSquare(121);      // 11 * 11 = 121
  }

  // Additional test cases
  method TestPerfectSquares() {
    // Test isPerfectSquare predicate
    assert isPerfectSquare(0);
    assert isPerfectSquare(1);
    assert isPerfectSquare(4);
    assert isPerfectSquare(9);
    assert isPerfectSquare(16);
    assert isPerfectSquare(25);
    assert isPerfectSquare(36);
    assert isPerfectSquare(49);
    assert isPerfectSquare(64);
    assert isPerfectSquare(81);
    assert isPerfectSquare(100);
    assert isPerfectSquare(121);
    
    // Test non-perfect squares
    assert !isPerfectSquare(2);
    assert !isPerfectSquare(3);
    assert !isPerfectSquare(5);
    assert !isPerfectSquare(6);
    assert !isPerfectSquare(7);
    assert !isPerfectSquare(8);
    assert !isPerfectSquare(10);
    assert !isPerfectSquare(15);
    assert !isPerfectSquare(24);
    assert !isPerfectSquare(99);
  }

  // Method to test the solution for different targets
  method TestVariousTargets() {
    // Test with target = 0
    var sol0 := findSmallestSolution(0);
    assert sol0 == 0;
    assert isPerfectSquare(0 + sol0);
    
    // Test with target = 1
    var sol1 := findSmallestSolution(1);
    assert sol1 == 0;
    assert isPerfectSquare(1 + sol1);
    
    // Test with target = 3
    var sol3 := findSmallestSolution(3);
    assert sol3 == 1;  // 3 + 1 = 4 = 2²
    assert isPerfectSquare(3 + sol3);
    
    // Test with target = 10
    var sol10 := findSmallestSolution(10);
    assert sol10 == 6;  // 10 + 6 = 16 = 4²
    assert isPerfectSquare(10 + sol10);
  }
}