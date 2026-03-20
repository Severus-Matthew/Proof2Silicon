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
  {
    style := "Improvised Farmhand Brawling";
    // Effectiveness calculation based on equipment and training
    var equipmentScore: real := equipment["Farm Tools as Weapons"] * 0.6;
    var trainingScore: real := if formalTraining then 0.7 else 0.2;
    var physicalScore: real := 0.3; // Malnourished youth
    effectiveness := (equipmentScore + trainingScore + physicalScore) / 3.0;
  }
  
  // Battle scenario against multiple opponents
  method BattleAgainstBards(bardCount: int) returns (survivalProbability: real)
    requires bardCount >= 1
    ensures 0.0 <= survivalProbability <= 1.0
  {
    var enemiesPerBard: int := 3;
    var totalEnemies: int := bardCount * enemiesPerBard;
    
    // Realistic survival probability for untrained peasant
    var baseSurvival: real := 0.1;
    var equipmentBonus: real := equipment["Farm Tools as Weapons"] * 0.1;
    var terrainBonus: real := 0.15; // Familiar with local terrain
    var numbersPenalty: real := 1.0 / (real(totalEnemies) * 0.5);
    
    survivalProbability := baseSurvival + equipmentBonus + terrainBonus - numbersPenalty;
    
    // Clamp to valid probability range
    if survivalProbability < 0.0 { survivalProbability := 0.0; }
    if survivalProbability > 1.0 { survivalProbability := 1.0; }
  }
  
  // Competition entry reasons (psychologically realistic for peasant youth)
  method CompetitionMotivations() returns (reasons: seq<string>)
    ensures |reasons| == 4
  {
    reasons := [
      "Economic desperation: Prize money could lift family from poverty",
      "Social advancement: Chance to escape peasant status",
      "Proving worth: Responding to local ridicule and low status",
      "Survival instinct: Fighting to protect remaining family assets"
    ];
  }
  
  // Cultural and historical accuracy validation
  method ValidateHistoricalAccuracy() returns (isAccurate: bool, deviations: seq<string>)
  {
    isAccurate := true;
    deviations := [];
    
    // Check historical plausibility
    if village != "Groom Farm" {
      isAccurate := false;
      deviations := deviations + ["Village name should reflect medieval English naming conventions"];
    }
    
    if age < 14 || age > 20 {
      isAccurate := false;
      deviations := deviations + ["Peasant youths typically worked from age 7, fought by mid-teens"];
    }
    
    // Verify equipment plausibility
    if equipment["Basic Armor"] > 0.1 {
      isAccurate := false;
      deviations := deviations + ["Peasants rarely owned metal armor due to sumptuary laws and cost"];
    }
    
    if equipment["Musical/Art Items"] > 0.0 {
      isAccurate := false;
      deviations := deviations + ["Peasants had no access to luxury art/music items"];
    }
  }
  
  // Resource allocation based on realistic medieval peasant economy
  method AllocateResources(budget: real) returns (optimalEquipment: map<string, real>)
    requires budget >= 0.0
    ensures forall item :: item in optimalEquipment.Keys ==> 0.0 <= optimalEquipment[item] <= 1.0
  {
    // Medieval peasant budget allocation priorities
    var foodAllocation: real := budget * 0.6;  # Survival first
    var toolAllocation: real := budget * 0.3;  # Work tools as weapons
    var clothAllocation: real := budget * 0.1; # Basic clothing/rags
    
    optimalEquipment := map[
      "Food Supplies" := if foodAllocation > 0.5 then 1.0 else foodAllocation * 2.0,
      "Farm Tools" := if toolAllocation > 0.4 then 0.8 else toolAllocation * 2.0,
      "Cloth Armor" := clothAllocation * 3.0,
      "Improvised Shield" := 0.2,
      "Projectiles" := 0.1
    ];
    
    // Normalize values
    for item in optimalEquipment.Keys 
      invariant forall i :: i in optimalEquipment.Keys ==> 0.0 <= optimalEquipment[i] <= 1.0
    {
      if optimalEquipment[item] > 1.0 {
        optimalEquipment[item] := 1.0;
      }
    }
  }
}

// Main verification method
method Main() {
  var edward: EdwardCarrotCharacter;
  edward := new EdwardCarrotCharacter();
  
  var style, effectiveness := edward.AnalyzeFightingStyle();
  print "Fighting Style: ", style, "\n";
  print "Effectiveness: ", effectiveness, "\n";
  
  var survival := edward.BattleAgainstBards(10);
  print "Survival Probability vs 10 bards (30 enemies): ", survival, "\n";
  
  var motivations := edward.CompetitionMotivations();
  print "\nCompetition Motivations:\n";
  for i := 0 to |motivations| - 1 {
    print "  ", i + 1, ". ", motivations[i], "\n";
  }
  
  var accurate, deviations := edward.ValidateHistoricalAccuracy();
  print "\nHistorically Accurate: ", accurate, "\n";
  if |deviations| > 0 {
    print "Deviations noted:\n";
    for d in deviations {
      print "  - ", d, "\n";
    }
  }
  
  var equipment := edward.AllocateResources(0.5);
  print "\nOptimal Equipment (0.5 budget):\n";
  for item in equipment.Keys {
    print "  ", item, ": ", equipment[item], "\n";
  }
}