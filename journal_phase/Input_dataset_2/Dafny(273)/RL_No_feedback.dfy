// Model for the system described in the problem
module SystemModel {
  
  // Basic types
  datatype Component = 
    | Tally
    | Opaque
    | Rub
    | Eye
    | Atom
    | Ballo
    | Arch
    | Pen
    | Amber
    | Silver
    | Crimson
    | Last
    | Next
    | Grand
    | Mirrored
    | Youthful
    | Faux
    | Lab
    | Band
    | Alloy
    | Pl
    | Sw
    | Ob
    | Ab
    | Ag
    | Apt
    | Snug
    | Sealed
    | Broadest
    | Inert
    | Touch
    | Electr
    | Stew
    | Dup
    | Remix
    | Unsub
    | Teen
    | Zest
    | Plug
    | Pne
    | Most
    | Accredited
    | Pro
    | Crib
    | Elect
    | Dangling
    | Plush
    | Collar
    | Stim
    | Penc
    | Ine
    | Beacon
    | Dim
    | Riv
    | Do
    | Fl
    | Wag
    | Depth
    | Caut
    | Clasmate
    | Pat
    | Early
    | Sole
    | Comm
    | Prox
    | Even
    | Buoy
    | Conver
    | Inverted
    | Interrogate
    | Tit
    | Branded
    | Fast
    | Crowcased
    | Diploma
    | Squ
    | Stom
    | Stead
    | Brid
    | Descent
    | Axe
    | Samtrib
    | Freezer
    | Ded
    | Swung
    | Near
    | Advancing
    | Estr
    | Right
    | Fit
    | Culnite
    | Consonate
    | Each
    | Excl
    | Local
    | Graft
    | Anom
    | Commanding
    | Anticipated
    | Brightest
    | Nearest
    | Swollen
    | Salacious
    | Fresh
    | Exchange
    | Courteous
    | Line
    | Malcul
    | Boxed
    | Velocity
    | Cum
    | App
    | Knife
    | Tra
    | Inclusive
    | Rope
    | Decductive
    | Blank
    | Vested
    | Amevity
    | Latest
    | Pinch
    | DedForensic
    | Antid
    | Acid
    | Opport
    | Fuse
    | Autos
    | Bite
    | Safety
    | Job
    | FlYouthful
    | Tech
    | Competacious
    | Cov
    | Bronze
    | Dead
    | Keen
    | Wax
    | Ass
    | Fut
    | Crow
    | Strat
    | Pace
    | Tight
    | Conc
    | Egg
    | Voyevity
    | Meas
    | Ev
    | Carc
    | Refined
    | Salt
    | Anatomy
    | Premium
    | Residual
    | Punitive
    | Remorse
    | Vamp
    | Fant
    | Stro
    | Accel
    | Rec
    | Ah
    | Nest
  
  // Relationship types
  datatype Relationship =
    | NextTo
    | LastOf
    | InertWith
    | MirroredBy
    | GrandOf
    | Touching
    | Descending
    | Ascending
    | Converging
    | InvertedBy
    | InterrogatedBy
    | BrandedAs
    | SealedWith
    | FitTo
    | BroadestOf
    | ConsonantWith
    | ExclusiveOf
    | LocalTo
    | GraftedOn
    | CommandingOf
    | AnticipatedBy
    | ExchangedWith
    | CourteousTo
    | DeductiveOf
    | VestedIn
    | AptFor
    | SafeWith
    | RefinedBy
    | AcceleratedBy
    | RecursiveOf
  
  // System state
  class SystemState {
    var components: set<Component>
    var relationships: map<(Component, Component), Relationship>
    var properties: map<Component, set<string>>
    
    constructor() 
      ensures components == {}
      ensures relationships == map[]
      ensures properties == map[]
    {
      components := {};
      relationships := map[];
      properties := map[];
    }
    
    method AddComponent(c: Component)
      ensures components == old(components) + {c}
      ensures properties.Keys == old(properties.Keys) + {c}
    {
      components := components + {c};
      if c !in properties then {
        properties := properties[c := {}];
      }
    }
    
    method AddRelationship(c1: Component, c2: Component, r: Relationship)
      requires c1 in components && c2 in components
      ensures relationships == old(relationships)[(c1, c2) := r]
    {
      relationships := relationships[(c1, c2) := r];
    }
    
    method AddProperty(c: Component, p: string)
      requires c in components
      ensures properties[c] == old(properties[c]) + {p}
    {
      properties := properties[c := properties[c] + {p}];
    }
    
    // Check if a component has a specific relationship
    method HasRelationship(c1: Component, c2: Component, r: Relationship) returns (has: bool)
      requires c1 in components && c2 in components
      ensures has == ((c1, c2) in relationships && relationships[(c1, c2)] == r)
    {
      has := (c1, c2) in relationships && relationships[(c1, c2)] == r;
    }
    
    // Get all components with a specific property
    method GetComponentsWithProperty(p: string) returns (result: set<Component>)
      ensures forall c :: c in result ==> c in components && p in properties[c]
      ensures forall c :: c in components && p in properties[c] ==> c in result
    {
      result := {};
      var comps := components;
      while comps != {}
        invariant result <= components
        invariant forall c :: c in result ==> p in properties[c]
        invariant forall c :: c in components && p in properties[c] && c !in comps ==> c in result
        decreases comps
      {
        var c :| c in comps;
        comps := comps - {c};
        if p in properties[c] {
          result := result + {c};
        }
      }
    }
    
    // Find the "last" component in a chain
    method FindLast(c: Component) returns (last: Component)
      requires c in components
      ensures last in components
      ensures !exists c2 :: c2 in components && (last, c2) in relationships && relationships[(last, c2)] == NextTo
    {
      last := c;
      var visited: set<Component> := {};
      
      while exists c2 :: c2 in components && (last, c2) in relationships && relationships[(last, c2)] == NextTo && c2 !in visited
        invariant last in components
        invariant visited <= components
        decreases |components| - |visited|
      {
        visited := visited + {last};
        var c2 :| c2 in components && (last, c2) in relationships && relationships[(last, c2)] == NextTo && c2 !in visited;
        last := c2;
      }
    }
    
    // Check if system is consistent
    method IsConsistent() returns (consistent: bool)
      ensures consistent ==> (forall c1, c2 :: (c1, c2) in relationships ==> c1 in components && c2 in components)
    {
      consistent := true;
      var rels := relationships.Keys;
      while rels != {}
        invariant consistent ==> (forall (c1, c2) :: (c1, c2) in relationships.Keys - rels ==> c1 in components && c2 in components)
        decreases rels
      {
        var (c1, c2) :| (c1, c2) in rels;
        rels := rels - {(c1, c2)};
        if c1 !in components || c2 !in components {
          consistent := false;
          return;
        }
      }
    }
  }
  
  // Main verification example
  method ExampleSystem() returns (state: SystemState)
    ensures state.IsConsistent()
  {
    state := new SystemState();
    
    // Add some components based on the description
    state.AddComponent(Tally);
    state.AddComponent(Opaque);
    state.AddComponent(Rub);
    state.AddComponent(Eye);
    state.AddComponent(Atom);
    state.AddComponent(Ballo);
    state.AddComponent(Arch);
    state.AddComponent(Pen);
    state.AddComponent(Amber);
    state.AddComponent(Crimson);
    
    // Add relationships based on the description
    // "tally next last" suggests a chain
    state.AddRelationship(Tally, Last, NextTo);
    state.AddRelationship(Last, Tally, LastOf);
    
    // "opaque tally" relationship
    state.AddRelationship(Opaque, Tally, Touching);
    
    // "rub eye" relationship
    state.AddRelationship(Rub, Eye, Touching);
    
    // "atom ballo" relationship
    state.AddRelationship(Atom, Ballo, GrandOf);
    
    // "arch pen" relationship
    state.AddRelationship(Arch, Pen, MirroredBy);
    
    // Add properties
    state.AddProperty(Tally, "crimson");
    state.AddProperty(Opaque, "silver");
    state.AddProperty(Atom, "hom");
    state.AddProperty(Ballo, "grand");
    state.AddProperty(Eye, "rev");
    state.AddProperty(Rub, "opaque");
    
    // Verify consistency
    var consistent := state.IsConsistent();
    assert consistent;
  }
  
  // Theorem: If A is next to B and B is next to C, then A is connected to C through B
  method TransitiveNextTheorem(state: SystemState, a: Component, b: Component, c: Component)
    requires state != null
    requires a in state.components && b in state.components && c in state.components
    requires state.HasRelationship(a, b, NextTo)
    requires state.HasRelationship(b, c, NextTo)
    ensures exists x :: x in state.components && state.HasRelationship(a, x, NextTo) && state.HasRelationship(x, c, NextTo)
  {
    // The proof follows directly from the premises
    // b serves as the intermediate component x
    assert state.HasRelationship(a, b, NextTo);
    assert state.HasRelationship(b, c, NextTo);
  }
  
  // Theorem: A component cannot be both inert and touching itself
  method NoSelfInertTouching(state: SystemState, c: Component)
    requires state != null
    requires c in state.components
    ensures !(state.HasRelationship(c, c, InertWith) && state.HasRelationship(c, c, Touching))
  {
    // By definition, a component cannot have both relationships with itself
    // This is an inherent property of the relationship definitions
  }
}