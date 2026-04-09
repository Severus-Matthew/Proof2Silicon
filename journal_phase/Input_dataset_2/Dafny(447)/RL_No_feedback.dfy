namespace SynchronizedModel {
  // Define states
  datatype State = State1 | State2 | State3
  
  class System {
    // Global variables
    var Number: set<int>
    var lastSyncTime: int
    var syncCount: int
    var currentState: State
    
    // State invariants
    predicate State1Invariant()
      reads this
    {
      currentState == State1 &&
      |Number| == 0 &&
      syncCount >= 0
    }
    
    predicate State2Invariant()
      reads this
    {
      currentState == State2 &&
      |Number| <= 1 &&
      syncCount > 0
    }
    
    predicate State3Invariant()
      reads this
    {
      currentState == State3 &&
      |Number| == 0 &&
      syncCount > 1
    }
    
    // Global invariant
    invariant 
      (currentState == State1 ==> State1Invariant()) &&
      (currentState == State2 ==> State2Invariant()) &&
      (currentState == State3 ==> State3Invariant())
    
    // Helper method for synchronization
    method SynchronizeJob()
      modifies this
      ensures syncCount == old(syncCount) + 1
      ensures lastSyncTime > old(lastSyncTime)
    {
      syncCount := syncCount + 1;
      lastSyncTime := lastSyncTime + 1;
    }
    
    // Transition from State3 to State1
    method TransitionFromState3ToState1() 
      modifies this
      requires currentState == State3
      requires |Number| == 0
      requires syncCount > 1
      ensures currentState == State1
      ensures syncCount == 1
      ensures |Number| == 0
    {
      // Synchronize before transition
      SynchronizeJob();
      
      // Transition logic - reduce syncCount to 1
      syncCount := 1;
      currentState := State1;
      
      // Verify postconditions
      assert currentState == State1;
      assert syncCount == 1;
      assert |Number| == 0;
    }
    
    // Transition from State2 to State1
    method TransitionFromState2ToState1() 
      modifies this
      requires currentState == State2
      requires |Number| <= 1
      requires syncCount > 0
      ensures currentState == State1
      ensures syncCount == 1
      ensures |Number| == 0
    {
      // Synchronize before transition
      SynchronizeJob();
      
      // Transition logic
      Number := {};
      syncCount := 1;
      currentState := State1;
      
      // Verify postconditions
      assert currentState == State1;
      assert syncCount == 1;
      assert |Number| == 0;
    }
    
    // Transition from State3 to State2
    method TransitionFromState3ToState2() 
      modifies this
      requires currentState == State3
      requires |Number| == 0
      requires syncCount > 1
      ensures currentState == State2
      ensures |Number| <= 1
      ensures syncCount > 0
    {
      // Synchronize before transition
      SynchronizeJob();
      
      // Transition logic - create a single value
      var singleValue: int := 0;
      Number := {singleValue};
      currentState := State2;
      
      // Verify postconditions
      assert currentState == State2;
      assert |Number| == 1;
      assert syncCount > 0;
    }
    
    // Initialization method
    method Init()
      modifies this
      ensures currentState == State1
      ensures State1Invariant()
    {
      Number := {};
      lastSyncTime := 0;
      syncCount := 0;
      currentState := State1;
    }
  }
}