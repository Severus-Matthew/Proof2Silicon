// Define a data type for a list of strings
datatype List = Nil | Cons(head: string, tail: List)

// Define a predicate to check if a list contains the string "apple"
function ContainsApple(l: List): bool
{
  match l
  case Nil => false
  case Cons(h, t) => h == "apple" || ContainsApple(t)
}

// Define the Store class to store a list that always contains "apple"
class Store {
  var storedList: List
  
  // Initialize the store with a list that contains "apple"
  method Init(l: List)
    requires ContainsApple(l)
    ensures Invariant()
  {
    storedList := l;
  }

  // Store a list that contains "apple"
  method StoreList(l: List)
    requires ContainsApple(l)
    ensures Invariant()
    ensures storedList == l
  {
    storedList := l;
  }

  // Invariant: the stored list always contains "apple"
  ghost predicate Invariant()
  {
    ContainsApple(storedList)
  }
}

// Define the Retrieve class to retrieve the list
class Retrieve {
  var store: Store
  
  constructor(initStore: Store)
    ensures store == initStore
  {
    store := initStore;
  }
  
  // Function to retrieve the list from the store
  method RetrieveList() returns (retrievedList: List)
    requires store.Invariant()
    ensures ContainsApple(retrievedList)
    ensures retrievedList == store.storedList
  {
    retrievedList := store.storedList;
  }
}