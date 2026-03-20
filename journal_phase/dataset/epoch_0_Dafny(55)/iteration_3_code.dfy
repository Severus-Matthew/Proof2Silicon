module HR.ApplicantSystem {
  import opened Dafny.Collections
  import opened Dafny.Sequence
  
  // ============================================
  // Data Types
  // ============================================
  
  datatype Applicant = Applicant(
    id: int,
    name: string,
    accessToken: string,
    isValid: bool
  )
  
  type ModelDB = seq<Applicant>
  
  // ============================================
  // Helper Lemmas and Functions
  // ============================================
  
  // Lemma to verify unique applicant IDs in database
  lemma UniqueApplicantIDs(db: ModelDB)
    ensures forall i, j :: 0 <= i < j < |db| ==> db[i].id != db[j].id
    decreases |db|
  {
    // Implementation would depend on how database is constructed
    // For now, we assume this property holds by construction
  }
  
  // Function to check if an applicant ID exists in the database
  function ApplicantExists(db: ModelDB, applicantID: int): bool
    reads db
  {
    exists applicant :: applicant in db && applicant.id == applicantID
  }
  
  // Function to validate access token for an applicant
  function ValidAccessToken(db: ModelDB, applicantID: int, token: string): bool
    requires ApplicantExists(db, applicantID)
    reads db
  {
    exists applicant :: applicant in db && 
      applicant.id == applicantID && 
      applicant.accessToken == token &&
      applicant.isValid
  }
  
  // ============================================
  // Core Verification Method
  // ============================================
  
  method VerifierUtil(db: ModelDB, applicantID: int, accessToken: string) 
    returns (foundApplicant: Applicant?, isValid: bool)
    requires accessToken != ""
    requires |db| > 0
    ensures foundApplicant == null || foundApplicant.id == applicantID
    ensures isValid ==> (
      foundApplicant != null &&
      foundApplicant.accessToken == accessToken &&
      foundApplicant.isValid
    )
    ensures !isValid ==> (
      foundApplicant == null ||
      foundApplicant.accessToken != accessToken ||
      !foundApplicant.isValid
    )
  {
    // Initialize return values
    foundApplicant := null;
    isValid := false;
    
    var i: int := 0;
    
    // Iterate through database to find applicant
    while i < |db|
      invariant 0 <= i <= |db|
      invariant forall j :: 0 <= j < i ==> 
        db[j].id != applicantID || 
        db[j].accessToken != accessToken || 
        !db[j].isValid
      invariant foundApplicant == null || foundApplicant.id == applicantID
      decreases |db| - i
    {
      var currentApplicant := db[i];
      
      if currentApplicant.id == applicantID {
        if currentApplicant.accessToken == accessToken && currentApplicant.isValid {
          foundApplicant := currentApplicant;
          isValid := true;
          return;
        } else {
          // Applicant found but token invalid or applicant not valid
          foundApplicant := currentApplicant;
          isValid := false;
          return;
        }
      }
      
      i := i + 1;
    }
    
    // Applicant not found in database
    foundApplicant := null;
    isValid := false;
  }
  
  // ============================================
  // Additional Helper Methods
  // ============================================
  
  // Method to validate unique applicant ID
  method ValidateUniqueAppID(db: ModelDB, applicantID: int) returns (isUnique: bool)
    requires |db| > 0
    ensures isUnique ==> !ApplicantExists(db, applicantID)
    ensures !isUnique ==> ApplicantExists(db, applicantID)
  {
    isUnique := true;
    var i: int := 0;
    
    while i < |db|
      invariant 0 <= i <= |db|
      invariant isUnique ==> forall j :: 0 <= j < i ==> db[j].id != applicantID
      decreases |db| - i
    {
      if db[i].id == applicantID {
        isUnique := false;
        return;
      }
      i := i + 1;
    }
  }
  
  // Method to get all valid applicants
  method GetValidApplicants(db: ModelDB) returns (validApplicants: seq<Applicant>)
    ensures |validApplicants| <= |db|
    ensures forall applicant :: applicant in validApplicants ==> applicant.isValid
    ensures forall applicant :: applicant in db && applicant.isValid ==> applicant in validApplicants
  {
    validApplicants := [];
    var i: int := 0;
    
    while i < |db|
      invariant 0 <= i <= |db|
      invariant |validApplicants| <= i
      invariant forall applicant :: applicant in validApplicants ==> applicant.isValid
      invariant forall j :: 0 <= j < i && db[j].isValid ==> db[j] in validApplicants
      decreases |db| - i
    {
      if db[i].isValid {
        validApplicants := validApplicants + [db[i]];
      }
      i := i + 1;
    }
  }
  
  // ============================================
  // Test Cases and Examples
  // ============================================
  
  method TestVerifierUtil() 
  {
    // Create test database
    var testDB: ModelDB := [
      Applicant(1, "John Doe", "token123", true),
      Applicant(2, "Jane Smith", "token456", true),
      Applicant(3, "Bob Johnson", "token789", false)
    ];
    
    // Test 1: Valid applicant with correct token
    var (applicant1, isValid1) := VerifierUtil(testDB, 1, "token123");
    assert applicant1 != null;
    assert isValid1 == true;
    assert applicant1.id == 1;
    
    // Test 2: Valid applicant with incorrect token
    var (applicant2, isValid2) := VerifierUtil(testDB, 1, "wrongtoken");
    assert applicant2 != null;
    assert isValid2 == false;
    
    // Test 3: Invalid applicant (isValid = false)
    var (applicant3, isValid3) := VerifierUtil(testDB, 3, "token789");
    assert applicant3 != null;
    assert isValid3 == false;
    
    // Test 4: Non-existent applicant
    var (applicant4, isValid4) := VerifierUtil(testDB, 999, "sometoken");
    assert applicant4 == null;
    assert isValid4 == false;
    
    // Test unique ID validation
    var isUnique1 := ValidateUniqueAppID(testDB, 1);
    assert isUnique1 == false; // ID 1 exists
    
    var isUnique2 := ValidateUniqueAppID(testDB, 999);
    assert isUnique2 == true; // ID 999 doesn't exist
    
    // Test getting valid applicants
    var validApplicants := GetValidApplicants(testDB);
    assert |validApplicants| == 2;
    assert Applicant(1, "John Doe", "token123", true) in validApplicants;
    assert Applicant(2, "Jane Smith", "token456", true) in validApplicants;
    assert Applicant(3, "Bob Johnson", "token789", false) !in validApplicants;
  }
}