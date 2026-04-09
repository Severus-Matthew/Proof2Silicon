method PopulationGrowth() returns (p1: real, p2: real, ratio: real)
  // Calculates population growth for two species with different growth rates
{
  // Initial population for both species
  var initial_population := 100.0;
  
  // Time period in years
  var t := 4.0;
  
  // Species 1: doubles every 2 years
  // Growth factor per 2 years: 2
  // Number of doubling periods in 4 years: 4/2 = 2
  // Total growth factor: 2^2 = 4
  var growth_factor1 := 4.0; // 2^(t/2) where t=4
  
  // Species 2: quadruples every 3 years  
  // Growth factor per 3 years: 4
  // Number of growth periods in 4 years: 4/3 ≈ 1.333...
  // Total growth factor: 4^(4/3) ≈ 6.3496
  var growth_factor2 := 6.349604207872797; // 4^(4/3) approximation
  
  // Calculate final populations
  p1 := initial_population * growth_factor1;
  p2 := initial_population * growth_factor2;
  
  // Calculate ratio as specified: 1 + (p1 - p2)/(p1 + p2)
  ratio := 1.0 + (p1 - p2) / (p1 + p2);
  
  // Postconditions to verify the calculations
  assert p1 == 400.0;
  assert p2 > 634.0 && p2 < 636.0;
  assert ratio > 0.77 && ratio < 0.78;
}