module System {
  // Types for different properties
  datatype Property = 
    | Opaque | Silver | Rub | Pen | Inert | Eye | Arch | Apt | Lateral
    | Grand | Blue | Legal | Last | Next | Near | Rev | Equ | Tally
    | Lumin | Faux | Cul | Band | Fest | Bour | Prism | Quick | Vene
    | Rapid | Sur | Brief | Brid | Fast | Pass | Tangible | Co | Esteem
    | Minimal | Neon | Chamber | Ob | Leg | Almost | For | Nest | Boot
    | Fre | Ev | Cogn | Pne | Cost | Jud | Core | Local | Atom | Cast
    | Div | Cad | Lad | Cl | Vest | Dup | Benign | Chain | Catal
    | Sal | Conson | Mis | Ab | Riv | Lit | Above | Whole | Frost | Prox
    | Limb | Gross | Descent | Hollow | Short | Vex | Pseud | Now
    | Amplified | Condol | Cos | Acqu | Abras | Any | Coer | Ve | Remix
    | Glow | Line | Saline | Vanity | Autos | Anne | Vital | Dec

  // Additional properties mentioned in the text
  const Most: Property := Dec  // Assigning a value to avoid uninitialized constant
  const App: Property := Dec   // Assigning a value to avoid uninitialized constant  
  const Lamp: Property := Dec  // Assigning a value to avoid uninitialized constant

  // State type with properties
  datatype State = State(properties: set<Property>)

  // Transition relation - fixed to properly check each rule
  predicate Transition(s1: State, s2: State) {
    s1 != s2 &&
    // Various transition rules based on the problem description
    // Each rule checks properties in s1 and ensures properties in s2
    ((Pen in s1.properties && Silver in s1.properties && Next in s2.properties) ||
    (Rub in s1.properties && Inert in s1.properties && Eye in s2.properties) ||
    (Opaque in s1.properties && Apt in s1.properties && Arch in s2.properties) ||
    (Lateral in s1.properties && Grand in s2.properties) ||
    (Last in s1.properties && Rev in s2.properties) ||
    (Near in s1.properties && App in s2.properties) ||
    (Equ in s1.properties && Tally in s2.properties) ||
    (Faux in s1.properties && Next in s2.properties) ||
    (Lumin in s1.properties && Apt in s2.properties) ||
    (Blue in s1.properties && Eye in s2.properties) ||
    (Legal in s1.properties && Next in s2.properties) ||
    (Cul in s1.properties && Next in s2.properties) ||
    (Vest in s1.properties && Dup in s2.properties) ||
    (Benign in s1.properties && Eye in s2.properties) ||
    (Chain in s1.properties && Catal in s2.properties) ||
    (Sal in s1.properties && Arch in s2.properties) ||
    (Conson in s1.properties && Mis in s2.properties) ||
    (Ab in s1.properties && Lateral in s2.properties) ||
    (Riv in s1.properties && Legal in s2.properties) ||
    (Lit in s1.properties && Pass in s2.properties) ||
    (Above in s1.properties && Most in s2.properties) ||
    (Whole in s1.properties && Frost in s2.properties) ||
    (Prox in s1.properties && Limb in s2.properties) ||
    (Gross in s1.properties && Rub in s2.properties) ||
    (Descent in s1.properties && Arch in s2.properties) ||
    (Hollow in s1.properties && Pne in s2.properties) ||
    (Short in s1.properties && Faux in s2.properties) ||
    (Vex in s1.properties && Pseud in s2.properties) ||
    (Now in s1.properties && Amplified in s2.properties) ||
    (Condol in s1.properties && Blue in s2.properties) ||
    (Cos in s1.properties && Acqu in s2.properties) ||
    (Abras in s1.properties && Lamp in s2.properties) ||
    (Any in s1.properties && Most in s2.properties) ||
    (Coer in s1.properties && Lumin in s2.properties) ||
    (Ve in s1.properties && Remix in s2.properties) ||
    (Glow in s1.properties && Local in s2.properties) ||
    (Line in s1.properties && Cl in s2.properties) ||
    (Saline in s1.properties && Prox in s2.properties) ||
    (Vanity in s1.properties && Silver in s2.properties) ||
    (Autos in s1.properties && Anne in s2.properties) ||
    (Vital in s1.properties && Inert in s2.properties) ||
    (Dec in s1.properties && Apt in s2.properties))
  }

  // System invariant: certain properties imply others
  predicate SystemInvariant(s: State) {
    ((Silver in s.properties && Pen in s.properties) ==> (Next in s.properties || Last in s.properties)) &&
    ((Rub in s.properties && Pen in s.properties) ==> (Eye in s.properties || Lateral in s.properties)) &&
    ((Opaque in s.properties && Apt in s.properties) ==> Arch in s.properties) &&
    ((Inert in s.properties) ==> (Eye in s.properties || Rub in s.properties)) &&
    ((Grand in s.properties) ==> Rub in s.properties) &&
    ((Legal in s.properties) ==> Next in s.properties) &&
    ((Blue in s.properties) ==> Eye in s.properties) &&
    ((Lateral in s.properties) ==> (Silver in s.properties || Rub in s.properties))
  }

  // Theorem: Starting from a state with certain properties,
  // we can reach states with other properties
  method ReachabilityTheorem(s0: State)
    requires SystemInvariant(s0)
    requires Pen in s0.properties && Silver in s0.properties
    ensures exists s: State :: Transition(s0, s) && Next in s.properties
  {
    // Create a state with Next property (different from s0)
    var s: State;
    
    if Next in s0.properties {
      // If Next is already in s0, we need a different state
      // Add a property that's not in s0 to make it different
      // We'll add Last since it's mentioned in the invariant
      s := State(s0.properties + {Last});
    } else {
      // If Next is not in s0, we can add it
      s := State(s0.properties + {Next});
    }
    
    // Check that s is different from s0
    assert s != s0;
    
    // The transition holds by the first rule
    // Pen && Silver in s0.properties && Next in s.properties
    assert Pen in s0.properties && Silver in s0.properties;
    assert Next in s.properties;
    
    // Therefore Transition(s0, s) holds
    // We need to explicitly show that one of the disjuncts in Transition is true
    assert (Pen in s0.properties && Silver in s0.properties && Next in s.properties);
    // This matches the first disjunct in Transition predicate
  }

  // Another theorem about opaque states
  method OpaqueTheorem(s0: State)
    requires SystemInvariant(s0)
    requires Opaque in s0.properties && Apt in s0.properties
    ensures exists s: State :: Transition(s0, s) && Arch in s.properties
  {
    // Create a state with Arch property
    var s: State;
    
    if Arch in s0.properties {
      // If Arch is already in s0, we need a different state
      // Add a property that's not in s0 to make it different
      s := State(s0.properties + {Lateral});
    } else {
      // If Arch is not in s0, we can add it
      s := State(s0.properties + {Arch});
    }
    
    // Check that s is different from s0
    assert s != s0;
    
    // The transition holds by the third rule
    // Opaque && Apt in s0.properties && Arch in s.properties
    assert Opaque in s0.properties && Apt in s0.properties;
    assert Arch in s.properties;
    
    // Therefore Transition(s0, s) holds
    // We need to explicitly show that one of the disjuncts in Transition is true
    assert (Opaque in s0.properties && Apt in s0.properties && Arch in s.properties);
    // This matches the third disjunct in Transition predicate
  }

  // Main verification of system properties
  method VerifySystemProperties() 
  {
    // Create some example states
    var silverPenState := State({Pen, Silver, Next});
    var opaqueAptState := State({Opaque, Apt, Arch});
    var rubInertState := State({Rub, Inert, Eye});
    
    // Verify invariants hold
    assert SystemInvariant(silverPenState);
    assert SystemInvariant(opaqueAptState);
    assert SystemInvariant(rubInertState);
    
    // Show transitions exist
    // For silverPenState, we can transition to a state with Last
    var s1 := State({Pen, Silver, Next, Last});
    // Check that s1 is different from silverPenState
    assert s1 != silverPenState;
    // Check transition condition: Pen && Silver in silverPenState.properties && Next in s1.properties
    assert Pen in silverPenState.properties && Silver in silverPenState.properties && Next in s1.properties;
    // Therefore Transition(silverPenState, s1) holds
    assert Transition(silverPenState, s1);
    assert Next in s1.properties;
    
    // For opaqueAptState, we can transition to a state with Lateral
    var s2 := State({Opaque, Apt, Arch, Lateral});
    assert s2 != opaqueAptState;
    assert Opaque in opaqueAptState.properties && Apt in opaqueAptState.properties && Arch in s2.properties;
    assert Transition(opaqueAptState, s2);
    assert Arch in s2.properties;
    
    // For rubInertState, we can transition to a state with Grand
    var s3 := State({Rub, Inert, Eye, Grand});
    assert s3 != rubInertState;
    assert Rub in rubInertState.properties && Inert in rubInertState.properties && Eye in s3.properties;
    assert Transition(rubInertState, s3);
    assert Eye in s3.properties;
  }
}