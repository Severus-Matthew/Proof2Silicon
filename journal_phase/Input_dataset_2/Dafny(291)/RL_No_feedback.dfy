module StateMachine {
  
  // Abstract state type
  trait State {
    predicate Valid()
    
    // Transition methods
    method Plunge() returns (s: State)
      ensures s.Valid()
    
    method Catalyze() returns (s: State)
      ensures s.Valid()
    
    method Rebound() returns (s: State)
      ensures s.Valid()
    
    method Dive() returns (s: State)
      ensures s.Valid()
  }
  
  // Concrete state: Premature
  class Premature extends State {
    predicate Valid() {
      true
    }
    
    constructor() {
      // Premature state has no fields to initialize
    }
    
    method Plunge() returns (s: State)
      ensures s.Valid()
    {
      s := new Youthful();
    }
    
    method Catalyze() returns (s: State)
      ensures s.Valid()
    {
      s := new Sterling();
    }
    
    method Rebound() returns (s: State)
      ensures s.Valid()
    {
      s := new Inert();
    }
    
    method Dive() returns (s: State)
      ensures s.Valid()
    {
      s := new Crimson();
    }
  }
  
  // Concrete state: Youthful
  class Youthful extends State {
    var digital: bool
    var orbital: bool
    
    predicate Valid() {
      digital || orbital
    }
    
    constructor() {
      digital := true;
      orbital := false;
    }
    
    method Plunge() returns (s: State)
      ensures s.Valid()
    {
      s := new Inert();
    }
    
    method Catalyze() returns (s: State)
      ensures s.Valid()
    {
      s := new Sterling();
    }
    
    method Rebound() returns (s: State)
      ensures s.Valid()
    {
      s := new Premature();
    }
    
    method Dive() returns (s: State)
      ensures s.Valid()
    {
      s := new Crimson();
    }
  }
  
  // Concrete state: Inert
  class Inert extends State {
    var viral: bool
    var centrifugal: bool
    
    predicate Valid() {
      viral != centrifugal
    }
    
    constructor() {
      viral := true;
      centrifugal := false;
    }
    
    method Plunge() returns (s: State)
      ensures s.Valid()
    {
      s := new Youthful();
    }
    
    method Catalyze() returns (s: State)
      ensures s.Valid()
    {
      s := new Sterling();
    }
    
    method Rebound() returns (s: State)
      ensures s.Valid()
    {
      s := new Premature();
    }
    
    method Dive() returns (s: State)
      ensures s.Valid()
    {
      s := new Crimson();
    }
  }
  
  // Concrete state: Crimson
  class Crimson extends State {
    var neon: bool
    var salient: bool
    
    predicate Valid() {
      neon && salient
    }
    
    constructor() {
      neon := true;
      salient := true;
    }
    
    method Plunge() returns (s: State)
      ensures s.Valid()
    {
      s := new Youthful();
    }
    
    method Catalyze() returns (s: State)
      ensures s.Valid()
    {
      s := new Sterling();
    }
    
    method Rebound() returns (s: State)
      ensures s.Valid()
    {
      s := new Inert();
    }
    
    method Dive() returns (s: State)
      ensures s.Valid()
    {
      s := new Premature();
    }
  }
  
  // Concrete state: Sterling
  class Sterling extends State {
    var guaranteed: bool
    var automated: bool
    
    predicate Valid() {
      guaranteed && automated
    }
    
    constructor() {
      guaranteed := true;
      automated := true;
    }
    
    method Plunge() returns (s: State)
      ensures s.Valid()
    {
      s := new Youthful();
    }
    
    method Catalyze() returns (s: State)
      ensures s.Valid()
    {
      s := new Inert();
    }
    
    method Rebound() returns (s: State)
      ensures s.Valid()
    {
      s := new Crimson();
    }
    
    method Dive() returns (s: State)
      ensures s.Valid()
    {
      s := new Premature();
    }
  }
  
  // Enhanced StateSystem with better validation
  class StateSystem {
    var current: State
    var history: seq<State>
    
    predicate Valid() {
      current != null && current.Valid() &&
      forall i | 0 <= i < |history| :: history[i] != null && history[i].Valid()
    }
    
    constructor() 
      ensures Valid()
    {
      current := new Premature();
      history := [current];
    }
    
    method Transition(action: int) returns (success: bool)
      requires Valid()
      ensures Valid()
      ensures success ==> |history| == old(|history|) + 1
      ensures !success ==> history == old(history)
    {
      var oldState := current;
      var newState: State;
      
      if action == 0 {
        newState := current.Plunge();
      } else if action == 1 {
        newState := current.Catalyze();
      } else if action == 2 {
        newState := current.Rebound();
      } else if action == 3 {
        newState := current.Dive();
      } else {
        success := false;
        return;
      }
      
      // Validate the transition
      if newState != null && newState.Valid() {
        current := newState;
        history := history + [current];
        success := true;
      } else {
        success := false;
      }
    }
    
    method GetCurrentStateType() returns (stateType: string)
      requires Valid()
    {
      // Use type tests instead of match statement
      if current is Premature {
        stateType := "Premature";
      } else if current is Youthful {
        stateType := "Youthful";
      } else if current is Inert {
        stateType := "Inert";
      } else if current is Crimson {
        stateType := "Crimson";
      } else if current is Sterling {
        stateType := "Sterling";
      } else {
        stateType := "Unknown";
      }
    }
    
    method ValidateTransition(fromState: string, action: string, toState: string) returns (valid: bool)
    {
      // Validate if a specific transition is allowed
      if fromState == "Premature" && action == "Plunge" && toState == "Youthful" {
        valid := true;
      } else if fromState == "Premature" && action == "Catalyze" && toState == "Sterling" {
        valid := true;
      } else if fromState == "Premature" && action == "Rebound" && toState == "Inert" {
        valid := true;
      } else if fromState == "Premature" && action == "Dive" && toState == "Crimson" {
        valid := true;
      } else if fromState == "Youthful" && action == "Plunge" && toState == "Inert" {
        valid := true;
      } else if fromState == "Youthful" && action == "Catalyze" && toState == "Sterling" {
        valid := true;
      } else if fromState == "Youthful" && action == "Rebound" && toState == "Premature" {
        valid := true;
      } else if fromState == "Youthful" && action == "Dive" && toState == "Crimson" {
        valid := true;
      } else if fromState == "Inert" && action == "Plunge" && toState == "Youthful" {
        valid := true;
      } else if fromState == "Inert" && action == "Catalyze" && toState == "Sterling" {
        valid := true;
      } else if fromState == "Inert" && action == "Rebound" && toState == "Premature" {
        valid := true;
      } else if fromState == "Inert" && action == "Dive" && toState == "Crimson" {
        valid := true;
      } else if fromState == "Crimson" && action == "Plunge" && toState == "Youthful" {
        valid := true;
      } else if fromState == "Crimson" && action == "Catalyze" && toState == "Sterling" {
        valid := true;
      } else if fromState == "Crimson" && action == "Rebound" && toState == "Inert" {
        valid := true;
      } else if fromState == "Crimson" && action == "Dive" && toState == "Premature" {
        valid := true;
      } else if fromState == "Sterling" && action == "Plunge" && toState == "Youthful" {
        valid := true;
      } else if fromState == "Sterling" && action == "Catalyze" && toState == "Inert" {
        valid := true;
      } else if fromState == "Sterling" && action == "Rebound" && toState == "Crimson" {
        valid := true;
      } else if fromState == "Sterling" && action == "Dive" && toState == "Premature" {
        valid := true;
      } else {
        valid := false;
      }
    }
    
    // New method to validate the entire history
    method ValidateHistory() returns (isValid: bool)
      requires Valid()
    {
      isValid := true;
      var i := 0;
      while i < |history|
        invariant 0 <= i <= |history|
        invariant forall j | 0 <= j < i :: history[j] != null && history[j].Valid()
      {
        if !history[i].Valid() {
          isValid := false;
          return;
        }
        i := i + 1;
      }
    }
    
    // New method to get transition sequence
    method GetTransitionSequence() returns (sequence: seq<string>)
      requires Valid()
    {
      sequence := [];
      var i := 0;
      while i < |history|
        invariant 0 <= i <= |history|
      {
        // Use type tests for each state in history
        if history[i] is Premature {
          sequence := sequence + ["Premature"];
        } else if history[i] is Youthful {
          sequence := sequence + ["Youthful"];
        } else if history[i] is Inert {
          sequence := sequence + ["Inert"];
        } else if history[i] is Crimson {
          sequence := sequence + ["Crimson"];
        } else if history[i] is Sterling {
          sequence := sequence + ["Sterling"];
        } else {
          // Should not happen since all states are valid
        }
        i := i + 1;
      }
    }
  }
  
  // Enhanced test method with better validation
  method TestStateMachine() 
  {
    var system := new StateSystem();
    var success: bool;
    
    // Start in Premature state
    var stateType := system.GetCurrentStateType();
    print "Initial state: ", stateType, "\n";
    
    // Validate initial state
    var isValid := system.ValidateHistory();
    print "Initial history valid: ", isValid, "\n";
    
    // Test sequence of transitions
    var actions: seq<int> := [0, 1, 2, 3, 0, 1];
    var i := 0;
    
    while i < |actions|
      invariant 0 <= i <= |actions|
    {
      success := system.Transition(actions[i]);
      if success {
        stateType := system.GetCurrentStateType();
        print "After action ", actions[i], ": ", stateType, "\n";
      } else {
        print "Failed transition for action ", actions[i], "\n";
      }
      i := i + 1;
    }
    
    // Get final transition sequence
    var sequence := system.GetTransitionSequence();
    print "Final state sequence: ", sequence, "\n";
    
    // Validate specific transitions
    isValid := system.ValidateTransition("Premature", "Plunge", "Youthful");
    print "Premature -> Plunge -> Youthful is valid: ", isValid, "\n";
    
    isValid := system.ValidateTransition("Youthful", "Dive", "Crimson");
    print "Youthful -> Dive -> Crimson is valid: ", isValid, "\n";
    
    // Validate entire history
    isValid := system.ValidateHistory();
    print "Final history valid: ", isValid, "\n";
  }
  
  // Main method for execution
  method Main() {
    TestStateMachine();
  }
}