module Main {
  // Define the different types/states mentioned in the problem
  datatype ItemType = 
    | SINGLE
    | DUAL
    | ATOMIC
    | ASSEMBLER
    | GENU
    | WANN
    | EROT
    | SNUG
    | TRUSTED
    | LOCAL
    | GLOBAL
    | VIRAL
    | VIRUS
    | PREDATORY
    | MECH
    | INERT
    | CHROME
    | SELF
    | CRIS
    | PREDPRO
    | EXCL
    | WELLGOLD
    | STERLING
    | JUVENILE
    | LEGIT
    | DANGLE
    | DOMESTIC
    | FATISR
    | CIVIC
    | BARE
    | SUPER
    | GOV
    | ONLY
    | GOLD
    | BIZ
    | TOY
    | OPEN
    | ENCLAVE
    | FAULTY
    | CULTIV
    | ANAL
    | EACH
    | HOE
    | DIVE
    | REMORSE
    | VIC
    | UNIQUE
    | TOUCH
    | REMOTE
    | INTEL
    | NEON
    | RELIC
    | ARCANE
    | SUS
    | NOOD
    | DEMON
    | BLUE
    | SILVER
    | ONLINE
    | AXIAL
    | ASIAN
    | PACE
    | SMO
    | BUDD
    | VEX
    | MUL
    | PROX
    | LANTERN
    | FRE
    | PERSONAL
    | FUNCTIONAL
    | ALL
    | VET
    | ABSOLUT
    | PERC
    | VACANT
    | WAG
    | VEH
    | BIZMIS
    | SQU
    | EMBR
    | JAP
    | GRAND
    | TARGETED
    | MIN
    | WEEKLY
    | SOLE
    | ICON
    | COZ
    | BANKING
    | PENN
    | ANOM
    | JR
    | HO
    | DB
    | AMERICA
    | TESTHIR
    | MOMMISE
    | ALO

  // Define an item record
  datatype Item = Item(
    id: int,
    itemType: ItemType,
    name: string,
    value: int
  )

  // Define a state for the system
  datatype SystemState = SystemState(
    items: seq<Item>,
    processedCount: int,
    lastType: ItemType
  )

  // Predicate to check if an item is valid
  predicate ValidItem(item: Item)
  {
    item.id >= 0 && item.value >= 0
  }

  // Additional validation predicates
  predicate ValidItemValue(item: Item)
  {
    // Check that value is within reasonable bounds
    item.value <= 1000000 && item.value >= 0
  }

  predicate ValidItemConsistency(item: Item)
  {
    // Check that item's value is consistent with itself
    item.value == item.value  // Always true, but demonstrates the pattern
  }

  predicate ValidItemAgainstCount(item: Item, count: int)
  {
    // Check that item value doesn't exceed count (if that makes sense for the domain)
    item.value <= count || count == 0
  }

  // Combined validation predicate
  predicate FullyValidItem(item: Item, currentCount: int)
  {
    ValidItem(item) &&
    ValidItemValue(item) &&
    ValidItemConsistency(item) &&
    ValidItemAgainstCount(item, currentCount)
  }

  // Predicate to check if two items can be paired
  predicate CanPair(item1: Item, item2: Item)
  {
    ValidItem(item1) && ValidItem(item2) &&
    (
      (item1.itemType == DUAL && item2.itemType == DUAL) ||
      (item1.itemType == GENU && item2.itemType == WANN) ||
      (item1.itemType == EROT && item2.itemType == SNUG) ||
      (item1.itemType == TRUSTED && item2.itemType == LOCAL) ||
      (item1.itemType == ATOMIC && item2.itemType == VIRAL) ||
      (item1.itemType == SINGLE && item2.itemType == SINGLE)
    )
  }

  // Function to process a single item
  function ProcessItem(state: SystemState, item: Item): SystemState
    requires ValidItem(item)
    ensures ProcessItem(state, item).processedCount == state.processedCount + 1
  {
    SystemState(
      state.items + [item],
      state.processedCount + 1,
      item.itemType
    )
  }

  // Method to process multiple items with full validation
  method ProcessItems(items: seq<Item>) returns (state: SystemState)
    requires forall i :: 0 <= i < |items| ==> ValidItem(items[i])
    ensures state.processedCount == |items|
  {
    state := SystemState([], 0, SINGLE);
    
    var i := 0;
    while i < |items|
      invariant 0 <= i <= |items|
      invariant state.processedCount == i
      invariant |state.items| == i
      invariant forall j :: 0 <= j < i ==> FullyValidItem(state.items[j], i)
    {
      // Additional validation check
      assert FullyValidItem(items[i], i);
      
      state := ProcessItem(state, items[i]);
      i := i + 1;
    }
  }

  // Predicate to validate the final state
  predicate ValidFinalState(state: SystemState)
  {
    state.processedCount == |state.items| &&
    (forall i :: 0 <= i < |state.items| ==> ValidItem(state.items[i])) &&
    (forall i :: 0 <= i < |state.items| ==> FullyValidItem(state.items[i], state.processedCount))
  }

  // Main method to demonstrate the system
  method Main()
  {
    // Create some test items
    var item1 := Item(1, SINGLE, "test1", 100);
    var item2 := Item(2, DUAL, "test2", 200);
    var item3 := Item(3, GENU, "test3", 300);
    var item4 := Item(4, WANN, "test4", 400);
    
    // Verify individual items are valid
    assert ValidItem(item1);
    assert ValidItem(item2);
    assert ValidItem(item3);
    assert ValidItem(item4);
    
    var items := [item1, item2, item3, item4];
    
    // Process the items
    var finalState := ProcessItems(items);
    
    // Verify the final state
    assert ValidFinalState(finalState);
    assert finalState.processedCount == 4;
    
    print "Processed ", finalState.processedCount, " items\n";
    print "Last item type: ", finalState.lastType, "\n";
    
    // Demonstrate pairing
    assert CanPair(item1, item1);  // SINGLE can pair with SINGLE
    assert CanPair(item3, item4);  // GENU can pair with WANN
  }
}