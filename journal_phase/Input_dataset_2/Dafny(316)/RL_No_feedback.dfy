module AtomicBoxSystem {
  
  // Type representing an atomic box with content
  datatype AtomicBox<T> = Box(content: T, version: nat, redundant: bool)
  
  // System state tracking all boxes
  class SystemState<T(==)> {
    var boxes: map<string, AtomicBox<T>>
    var testsPassed: map<string, bool>
    
    // Constructor to initialize the state
    constructor()
      ensures Valid()
    {
      boxes := map[];
      testsPassed := map[];
    }
    
    predicate Valid()
      reads this
    {
      // All boxes must have version > 0
      (forall name :: name in boxes ==> boxes[name].version > 0) &&
      // All boxes must have passed their tests if they're in testsPassed
      (forall name :: name in testsPassed ==> testsPassed[name] == true) &&
      // All non-redundant boxes must have passed tests
      (forall name :: name in boxes && !boxes[name].redundant ==> name in testsPassed)
    }
    
    // Check if a box contains a specific value
    method ContainsValue(name: string, value: T) returns (contains: bool)
      requires name in boxes
      ensures contains == (boxes[name].content == value)
    {
      contains := boxes[name].content == value;
    }
    
    // Check if any box contains a specific value
    method ContainsValueAnywhere(value: T) returns (found: bool, name: string)
      ensures found ==> name in boxes && boxes[name].content == value
      ensures !found ==> name == ""
    {
      found := false;
      name := "";
      var boxNames := boxes.Keys;
      
      while boxNames != {}
        invariant !found ==> forall n :: n in boxNames ==> boxes[n].content != value
        invariant found ==> name in old(boxes.Keys) && boxes[name].content == value
      {
        var n :| n in boxNames;
        boxNames := boxNames - {n};
        
        if boxes[n].content == value {
          found := true;
          name := n;
          return;
        }
      }
    }
    
    // Create a new atomic box
    method CreateBox(name: string, content: T, makeRedundant: bool)
      requires name !in boxes
      ensures name in boxes
      ensures boxes[name].content == content
      ensures boxes[name].redundant == makeRedundant
      ensures boxes[name].version == 1
      modifies this
    {
      boxes := boxes[name := Box(content, 1, makeRedundant)];
    }
    
    // Update box content with version increment
    method UpdateBox(name: string, newContent: T)
      requires name in boxes
      ensures boxes[name].content == newContent
      ensures boxes[name].version == old(boxes[name].version) + 1
      ensures boxes[name].redundant == old(boxes[name].redundant)
      modifies this
    {
      var oldBox := boxes[name];
      boxes := boxes[name := Box(newContent, oldBox.version + 1, oldBox.redundant)];
    }
    
    // Run sanity test on a box - now with actual validation logic
    method RunTest(name: string) returns (passed: bool)
      requires name in boxes
      ensures testsPassed[name] == passed
      modifies this
    {
      var box := boxes[name];
      
      // Actual test logic based on type T
      // For demonstration, we'll use a simple test:
      // For integers: check if content is positive
      // For strings: check if content is non-empty
      // For other types: always pass (since we can't know what's valid)
      
      // We need to handle different types differently
      // This is a limitation of Dafny's generics
      // We'll use a simple approach that works for common cases
      
      if box.content is int {
        var intContent := box.content as int;
        passed := intContent > 0;
      } else if box.content is string {
        var stringContent := box.content as string;
        passed := stringContent != "";
      } else {
        // For other types, we can't determine validity, so we pass by default
        passed := true;
      }
      
      testsPassed := testsPassed[name := passed];
    }
    
    // Validate a specific box
    method ValidateBox(name: string) returns (valid: bool)
      requires name in boxes
      ensures valid ==> (boxes[name].version > 0 && (name in testsPassed ==> testsPassed[name] == true))
    {
      var box := boxes[name];
      valid := box.version > 0;
      
      if name in testsPassed {
        valid := valid && testsPassed[name];
      }
    }
    
    // Get redundant boxes
    method GetRedundantBoxes() returns (redundantNames: set<string>)
      ensures forall name :: name in redundantNames ==> boxes[name].redundant
    {
      redundantNames := {};
      var names := boxes.Keys;
      while names != {}
        invariant forall n :: n in redundantNames ==> boxes[n].redundant
        invariant forall n :: n in names - redundantNames ==> !boxes[n].redundant
      {
        var name :| name in names;
        names := names - {name};
        if boxes[name].redundant {
          redundantNames := redundantNames + {name};
        }
      }
    }
    
    // Validate the entire system
    method ValidateSystem() returns (valid: bool)
      ensures valid ==> Valid()
    {
      valid := Valid();
    }
    
    // Mass validation check - checks all boxes
    method MassValidation() returns (allValid: bool)
      ensures allValid ==> Valid()
    {
      allValid := true;
      var boxNames := boxes.Keys;
      
      while boxNames != {}
        invariant allValid ==> forall n :: n in boxNames ==> boxes[n].version > 0
      {
        var name :| name in boxNames;
        boxNames := boxNames - {name};
        
        var boxValid := ValidateBox(name);
        if !boxValid {
          allValid := false;
        }
      }
      
      // Also check that all non-redundant boxes have passed tests
      if allValid {
        boxNames := boxes.Keys;
        while boxNames != {}
          invariant allValid ==> forall n :: n in boxNames && !boxes[n].redundant ==> n in testsPassed
        {
          var name :| name in boxNames;
          boxNames := boxNames - {name};
          
          if !boxes[name].redundant && name !in testsPassed {
            allValid := false;
          }
        }
      }
    }
  }
}

// Test module outside the main module to avoid visibility issues
module Tests {
  import opened AtomicBoxSystem
  
  method TestBasicOperations()
  {
    var system := new SystemState<int>();
    
    // Create some boxes
    system.CreateBox("box1", 42, true);
    system.CreateBox("box2", 100, false);
    
    // Verify boxes exist
    assert "box1" in system.boxes;
    assert "box2" in system.boxes;
    
    // Test ContainsValue method
    var contains1 := system.ContainsValue("box1", 42);
    assert contains1;
    
    var contains2 := system.ContainsValue("box2", 100);
    assert contains2;
    
    // Test ContainsValueAnywhere
    var foundResult := system.ContainsValueAnywhere(42);
    var found := foundResult.0;
    var name := foundResult.1;
    assert found && name == "box1";
    
    // Update a box
    system.UpdateBox("box1", 84);
    assert system.boxes["box1"].content == 84;
    assert system.boxes["box1"].version == 2;
    
    // Run tests
    var passed1 := system.RunTest("box1");
    var passed2 := system.RunTest("box2");
    assert passed1 && passed2;
    
    // Validate individual boxes
    var valid1 := system.ValidateBox("box1");
    var valid2 := system.ValidateBox("box2");
    assert valid1 && valid2;
    
    // Get redundant boxes
    var redundant := system.GetRedundantBoxes();
    assert "box1" in redundant;
    assert !("box2" in redundant);
    
    // Validate system
    var valid := system.ValidateSystem();
    assert valid;
    
    // Mass validation
    var massValid := system.MassValidation();
    assert massValid;
  }
  
  method TestValidation()
  {
    var system := new SystemState<string>();
    
    system.CreateBox("test", "content", false);
    var testResult := system.RunTest("test");
    
    // System should be valid after successful test
    assert system.Valid();
    
    // Test ContainsValue with strings
    var contains := system.ContainsValue("test", "content");
    assert contains;
    
    // Test ContainsValueAnywhere with strings
    var foundResult := system.ContainsValueAnywhere("content");
    var found := foundResult.0;
    var name := foundResult.1;
    assert found && name == "test";
  }
  
  method TestInvalidBox()
  {
    var system := new SystemState<int>();
    
    system.CreateBox("test", -1, false);
    // RunTest should fail for negative values
    var testResult := system.RunTest("test");
    
    // Box should still be valid structurally
    var boxValid := system.ValidateBox("test");
    assert boxValid; // Version > 0, so valid
    
    // But system should not be valid since non-redundant box failed test
    assert !system.Valid(); // Non-redundant box failed test
  }
  
  method TestEmptyStringBox()
  {
    var system := new SystemState<string>();
    
    system.CreateBox("empty", "", false);
    // RunTest should fail for empty strings
    var testResult := system.RunTest("empty");
    
    // System should not be valid
    assert !system.Valid();
  }
}

// Main demonstration
method Main()
{
  // Run tests
  Tests.TestBasicOperations();
  Tests.TestValidation();
  Tests.TestInvalidBox();
  Tests.TestEmptyStringBox();
  
  print "All operations completed successfully!\n";
}