module Poisson2D {
  // Grid parameters
  const gridSizeX: int := 10
  const gridSizeY: int := 10
  const h: real := 1.0
  
  // Grid indices (0-based for array access)
  ghost predicate ValidGridIndex(i: int, j: int) 
  {
    0 <= i < gridSizeX && 0 <= j < gridSizeY
  }
  
  // Solution array - using 2D arrays
  class Solver {
    var u: array2<real>
    var f: array2<real>
    
    // Initialize arrays
    method Init() 
      modifies this
      ensures u.Length0 == gridSizeX && u.Length1 == gridSizeY
      ensures f.Length0 == gridSizeX && f.Length1 == gridSizeY
    {
      u := new real[gridSizeX, gridSizeY];
      f := new real[gridSizeX, gridSizeY];
      
      // Initialize to zero using for loops
      var i: int := 0;
      while i < gridSizeX
        invariant 0 <= i <= gridSizeX
      {
        var j: int := 0;
        while j < gridSizeY
          invariant 0 <= j <= gridSizeY
        {
          u[i, j] := 0.0;
          f[i, j] := 0.0;
          j := j + 1;
        }
        i := i + 1;
      }
    }
    
    // Set boundary conditions (Dirichlet boundary conditions)
    method SetBoundaryConditions()
      modifies u
      requires u.Length0 == gridSizeX && u.Length1 == gridSizeY
    {
      // Set boundary values to zero (homogeneous Dirichlet)
      var i: int := 0;
      while i < gridSizeX
        invariant 0 <= i <= gridSizeX
      {
        u[i, 0] := 0.0;                    // bottom boundary
        u[i, gridSizeY - 1] := 0.0;        // top boundary
        i := i + 1;
      }
      
      var j: int := 0;
      while j < gridSizeY
        invariant 0 <= j <= gridSizeY
      {
        u[0, j] := 0.0;                    // left boundary
        u[gridSizeX - 1, j] := 0.0;        // right boundary
        j := j + 1;
      }
    }
    
    // Set right-hand side function f(x,y)
    method SetRHS(value: real)
      modifies f
      requires f.Length0 == gridSizeX && f.Length1 == gridSizeY
    {
      // Set all interior points to the given value
      var i: int := 1;
      while i < gridSizeX - 1
        invariant 1 <= i <= gridSizeX - 1
      {
        var j: int := 1;
        while j < gridSizeY - 1
          invariant 1 <= j <= gridSizeY - 1
        {
          f[i, j] := value;
          j := j + 1;
        }
        i := i + 1;
      }
    }
    
    // Optimized RHS computation based on the provided suggestions
    method ComputeOptimizedRHS(a: real)
      modifies f
      requires u.Length0 == gridSizeX && u.Length1 == gridSizeY
      requires f.Length0 == gridSizeX && f.Length1 == gridSizeY
    {
      // Using the optimized approach from the instructions
      // Note: This is a different formulation than the original Poisson equation
      // It's based on the provided optimization suggestions
      var i: int := 1;
      while i < gridSizeX - 1
        invariant 1 <= i <= gridSizeX - 1
      {
        var j: int := 1;
        while j < gridSizeY - 1
          invariant 1 <= j <= gridSizeY - 1
        {
          // Optimized computation based on the provided formula
          // Using a simplified version that works with our grid boundaries
          if i + 1 < gridSizeX && j + 1 < gridSizeY {
            f[i, j] := a * (u[i, j] - 2.0 * u[i, j + 1] + u[i + 1, j] - u[i, j] + 1.0) 
                       / (1.0 + (u[i + 1, j] - 2.0 * u[i, j + 1] + u[i + 1, j + 1] - u[i, j] + 1.0 / a));
          }
          j := j + 1;
        }
        i := i + 1;
      }
    }
    
    // Finite difference approximation of Laplacian
    function LaplacianAt(i: int, j: int): real
      requires 1 <= i < gridSizeX - 1
      requires 1 <= j < gridSizeY - 1
      reads u
    {
      // Standard 5-point stencil for 2D Laplacian
      // ∇²u ≈ (u[i-1,j] + u[i+1,j] + u[i,j-1] + u[i,j+1] - 4*u[i,j]) / h²
      (u[i-1, j] + u[i+1, j] + u[i, j-1] + u[i, j+1] - 4.0 * u[i, j]) / (h * h)
    }
    
    // Jacobi iteration for solving Poisson equation
    method JacobiIteration(tolerance: real, maxIterations: int) returns (iterations: int)
      modifies u
      requires u.Length0 == gridSizeX && u.Length1 == gridSizeY
      requires f.Length0 == gridSizeX && f.Length1 == gridSizeY
      requires tolerance > 0.0
      requires maxIterations > 0
      ensures 0 <= iterations <= maxIterations
    {
      var u_new: array2<real> := new real[gridSizeX, gridSizeY];
      var error: real;
      iterations := 0;
      
      // Copy boundary conditions
      SetBoundaryConditions();
      
      while iterations < maxIterations
        invariant 0 <= iterations <= maxIterations
        invariant u_new.Length0 == gridSizeX && u_new.Length1 == gridSizeY
      {
        // Copy boundary values
        var i: int := 0;
        while i < gridSizeX
          invariant 0 <= i <= gridSizeX
        {
          u_new[i, 0] := u[i, 0];
          u_new[i, gridSizeY - 1] := u[i, gridSizeY - 1];
          i := i + 1;
        }
        
        var j: int := 0;
        while j < gridSizeY
          invariant 0 <= j <= gridSizeY
        {
          u_new[0, j] := u[0, j];
          u_new[gridSizeX - 1, j] := u[gridSizeX - 1, j];
          j := j + 1;
        }
        
        error := 0.0;
        
        // Jacobi update for interior points
        i := 1;
        while i < gridSizeX - 1
          invariant 1 <= i <= gridSizeX - 1
        {
          j := 1;
          while j < gridSizeY - 1
            invariant 1 <= j <= gridSizeY - 1
          {
            // Jacobi update formula for Poisson equation:
            // u_new[i,j] = 0.25 * (u[i-1,j] + u[i+1,j] + u[i,j-1] + u[i,j+1] - h² * f[i,j])
            u_new[i, j] := 0.25 * (u[i-1, j] + u[i+1, j] + u[i, j-1] + u[i, j+1] - h * h * f[i, j]);
            
            // Update error (maximum absolute difference)
            var diff := u_new[i, j] - u[i, j];
            if diff < 0.0 {
              diff := -diff;
            }
            if diff > error {
              error := diff;
            }
            j := j + 1;
          }
          i := i + 1;
        }
        
        // Check convergence
        if error < tolerance {
          break;
        }
        
        // Swap arrays for next iteration
        var temp := u;
        u := u_new;
        u_new := temp;
        
        iterations := iterations + 1;
      }
    }
  }
  
  // Main method to test the Poisson solver
  method Main()
  {
    var solver := new Solver;
    
    // Initialize
    solver.Init();
    
    // Set boundary conditions
    solver.SetBoundaryConditions();
    
    // Test 1: Constant source term
    solver.SetRHS(1.0);
    
    // Solve using Jacobi iteration
    var iterations := solver.JacobiIteration(0.000001, 1000);
    
    print "Test 1 - Constant source:\n";
    print "Poisson equation solved in ", iterations, " iterations\n";
    print "Solution at center point u[", gridSizeX/2, ",", gridSizeY/2, "] = ", solver.u[gridSizeX/2, gridSizeY/2], "\n";
    
    // Test 2: Optimized RHS computation
    solver.Init();  // Reset
    solver.SetBoundaryConditions();
    
    // Use the optimized RHS computation
    solver.ComputeOptimizedRHS(1.0);
    
    iterations := solver.JacobiIteration(0.000001, 1000);
    
    print "\nTest 2 - Optimized RHS:\n";
    print "Poisson equation solved in ", iterations, " iterations\n";
    print "Solution at center point u[", gridSizeX/2, ",", gridSizeY/2, "] = ", solver.u[gridSizeX/2, gridSizeY/2], "\n";
    
    // Verify solution satisfies discrete Poisson equation at interior points
    var i: int := 1;
    while i < gridSizeX - 1
      invariant 1 <= i <= gridSizeX - 1
    {
      var j: int := 1;
      while j < gridSizeY - 1
        invariant 1 <= j <= gridSizeY - 1
      {
        // Check that ∇²u ≈ f at each interior point
        var laplacian := solver.LaplacianAt(i, j);
        var residual := laplacian - solver.f[i, j];
        // Residual should be small (but not exactly zero due to iterative method)
        assert residual * residual < 0.0001; // Allow some tolerance
        j := j + 1;
      }
      i := i + 1;
    }
  }
}