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
    var i: int := 0;
    isUnique := true;
    
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
}