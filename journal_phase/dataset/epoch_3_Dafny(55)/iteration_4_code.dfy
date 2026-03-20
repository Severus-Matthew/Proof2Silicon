/**
 * Character: Edward Carrot
 * Age: 17
 * Origin: Groom Farm village (peasant farming community, no formal warrior guilds)
 * Historical Context: Late medieval/early Renaissance rural England (circa 1400-1450)
 * Social Rank: Low peasant (damned low ranking)
 * Combat Style: Pragmatic survivalist, using improvised tools and scavenged gear
 * Cultural Accuracy: Reflects impoverished rural English peasantry with no access to formal military training
 */

class EdwardCarrotCharacter {
  // Core identity
  var age: int := 17;
  var village: string := "Groom Farm";
  var socialRank: string := "Peasant (Lowest)";
  
  // Historical context - medieval English peasantry
  var historicalPeriod: string := "Late Medieval England (c. 1400-1450)";
  var economicStatus: string := "Impoverished";
  var formalTraining: bool := false;
  
  // Physical characteristics (realistic for malnourished peasant youth)
  var height: real := 1.65; // meters (short due to poor nutrition)
  var weight: real := 55.0; // kg
  var build: string := "Lean, underdeveloped musculature";
  
  // Combat capabilities (realistically limited)
  var combatExperience: int := 0; // Formal battles fought
  var survivalExperience: int := 8; // Years of farm labor provides some strength
  var weaponProficiency: set<string> := {"Improvised Tools", "Farm Implements"};
  
  // Equipment inventory (what he can realistically afford/acquire)
  ghost var equipment: map<string, real> := 
    map[
      "Food Supplies (elderly)" := 0.3,  // 30% adequate nutrition
      "Personal Melee Shield" := 0.1,     // Crude wooden plank with leather straps
      "Ammunition Small" := 0.05,         // Few stones/improvised projectiles
      "Farm Tools as Weapons" := 0.8,     // Scythe, hoe, pitchfork
      "Basic Armor" := 0.0,              // No metal armor, only layered rags
      "Specialized Gear" := 0.0,         // Cannot afford
      "Musical/Art Items" := 0.0         // No luxury items
    ];
  
  // Fighting style analysis
  method AnalyzeFightingStyle() returns (style: string, effectiveness: real) 
    ensures style in {"Improvised", "Defensive", "Reckless"}
    ensures 0.0 <= effectiveness <= 1.0
    ensures village == old(village)  // Village remains unchanged
    ensures socialRank == old(socialRank)  // Social rank preserved
  {
    style := "Improvised Farmhand Brawling";
    // Effectiveness calculation based on equipment and training
    var equipmentScore: real := equipment["Farm Tools as Weapons"] * 0.6;
    var trainingScore: real := if formalTraining then 0.7 else 0.2;
    var physicalScore: real := 0.3; // Malnourished youth
    effectiveness := (equipmentScore + trainingScore + physicalScore) / 3;
  }
}

// Supporting structures for data representation
struct n1 {
  var data: int;
}

struct n2 {
  var data: int;
}

struct n3 {
  var data: int;
}

// Array utility with preservation guarantees
function ArrayPreservation<T>(xs: seq<T>): (arr: array<T>)
  ensures arr.Length == |xs|
  ensures forall i: int :: 0 <= i < arr.Length ==> arr[i] == xs[i]
  ensures fresh(arr)  // Newly allocated array
{
  var arr := new T[|xs|];
  var i := 0;
  while i < |xs|
    invariant 0 <= i <= |xs|
    invariant forall j: int :: 0 <= j < i ==> arr[j] == xs[j]
  {
    arr[i] := xs[i];
    i := i + 1;
  }
  arr
}

// Example usage demonstrating preservation
method ExampleUsage() {
  var character := new EdwardCarrotCharacter();
  var (style, effectiveness) := character.AnalyseFightingStyle();
  assert style in {"Improvised", "Defensive", "Reckless"};
  assert 0.0 <= effectiveness <= 1.0;
  
  // Demonstrate array preservation
  var seqData: seq<int> := [1, 2, 3];
  var arr := ArrayPreservation(seqData);
  assert arr.Length == 3;
  assert arr[0] == 1 && arr[1] == 2 && arr[2] == 3;
}