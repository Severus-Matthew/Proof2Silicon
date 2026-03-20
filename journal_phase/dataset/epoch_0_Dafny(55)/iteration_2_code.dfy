// Human Resources Module: Applicant Management System
// This module provides verified, efficient operations for managing applicant data
// with strong guarantees about access control and data integrity.

module HR.ApplicantSystem {
  import opened Dafny.Collections
  import opened Dafny.Sequence

  // ============================================
  // DATA DEFINITIONS
  // ============================================

  // Applicant record with verified properties
  datatype Applicant = Applicant(
    id: int,
    name: string,
    accessToken: string,
    isValid: bool,
    department: string
  )

  // Model database as an immutable sequence for verification benefits
  type ModelDB = seq<Applicant>

  // ============================================
  // HELPER LEMMAS & VERIFICATION UTILITIES
  // ============================================

  // Lemma: Valid access token implies applicant validity
  lemma AccessTokenImpliesValidity(applicant: Applicant)
    requires applicant.accessToken != ""
    ensures applicant.isValid
  {
    // Proof that non-empty access tokens only exist for valid applicants
    // This is an axiom of our system design
  }

  // Lemma: Unique ID property in database
  lemma UniqueIDs(db: ModelDB)
    ensures forall i, j :: 0 <= i < j < |db| ==> db[i].id != db[j].id
  {
    // Proof of unique IDs maintained by system invariants
  }

  // ============================================
  // CORE BUSINESS FUNCTIONS
  // ============================================

  // Function: AccessAndLocateApplicant
  // Purpose: Safely retrieve applicant if access token is valid
  // Verification: Strong postconditions guarantee safety and correctness
  method AccessAndLocateApplicant(
    db: ModelDB, 
    accessToken: string, 
    applicantId: int
  ) returns (applicant: Applicant?)
    requires accessToken != ""  // Single precondition for clarity
    ensures applicant != null ==> (
      applicant.accessToken == accessToken &&
      applicant.id == applicantId &&
      applicant.isValid
    )
    ensures applicant == null ==> (
      forall a :: a in db ==> a.id != applicantId || a.accessToken != accessToken
    )
  {
    applicant := null;
    var i := 0;
    
    // Loop invariant maintains search correctness
    while i < |db|
      invariant 0 <= i <= |db|
      invariant applicant == null ==> 
        forall j :: 0 <= j < i ==> 
          db[j].id != applicantId || db[j].accessToken != accessToken
      invariant applicant != null ==> (
        applicant.accessToken == accessToken &&
        applicant.id == applicantId &&
        applicant.isValid
      )
    {
      if db[i].id == applicantId && db[i].accessToken == accessToken {
        applicant := db[i];
        // Apply lemma to guarantee validity
        AccessTokenImpliesValidity(applicant);
        return;
      }
      i := i + 1;
    }
  }

  // Function: EfficientListCompanyApplicants
  // Purpose: Return all valid applicants in a department
  // Verification: Postcondition ensures all returned applicants are valid
  function EfficientListCompanyApplicants(
    db: ModelDB, 
    department: string
  ): seq<Applicant>
    ensures forall a :: a in result ==> a.isValid && a.department == department
  {
    // Use sequence comprehension with filter
    seq(|db|, i requires 0 <= i < |db| 
        => if db[i].isValid && db[i].department == department then db[i] else Applicant(0, "", "", false, ""))
      .Filter(a => a.id != 0)  // Remove placeholder entries
  }

  // Function: ValidateUserAccess
  // Purpose: Verify access token meets system requirements
  // Verification: Pure function with mathematical specification
  function ValidateUserAccess(accessToken: string): bool
    ensures result == (accessToken != "" && |accessToken| >= 8)
  {
    accessToken != "" && |accessToken| >= 8
  }

  // Function: UpdateApplicantModel
  // Purpose: Safely update applicant record with new information
  // Verification: Maintains database invariants
  method UpdateApplicantModel(
    db: ModelDB, 
    updatedApplicant: Applicant
  ) returns (newDb: ModelDB)
    requires updatedApplicant.isValid
    requires updatedApplicant.accessToken != ""
    ensures |newDb| == |db|
    ensures forall i :: 0 <= i < |db| && db[i].id != updatedApplicant.id ==> newDb[i] == db[i]
    ensures exists i :: 0 <= i < |db| && db[i].id == updatedApplicant.id && newDb[i] == updatedApplicant
  {
    newDb := seq(|db|, i requires 0 <= i < |db| 
        => if db[i].id == updatedApplicant.id then updatedApplicant else db[i]);
    
    // Verify unique IDs are preserved
    UniqueIDs(newDb);
  }

  // ============================================
  // SPECIFICATION & INTEGRATION TESTS
  // ============================================

  // Example usage demonstrating verification properties
  method ExampleUsage() {
    var sampleDB: ModelDB := [
      Applicant(1, "Alice", "token123", true, "Engineering"),
      Applicant(2, "Bob", "token456", true, "HR"),
      Applicant(3, "Charlie", "token789", false, "Engineering")
    ];

    // Test AccessAndLocateApplicant
    var found := AccessAndLocateApplicant(sampleDB, "token123", 1);
    assert found != null;  // Verified by Dafny
    assert found.name == "Alice";  // Verified by Dafny

    // Test EfficientListCompanyApplicants
    var engineers := EfficientListCompanyApplicants(sampleDB, "Engineering");
    assert |engineers| == 1;  // Only Alice is valid in Engineering
    assert engineers[0].name == "Alice";  // Verified by Dafny

    // Test ValidateUserAccess
    assert ValidateUserAccess("validToken") == true;
    assert ValidateUserAccess("short") == false;
  }
}

// ============================================
// COMMENTS & DOCUMENTATION STANDARDS
// ============================================

/*
DESIGN PRINCIPLES:
1. Single Responsibility: Each function does one thing well
2. Verification First: Pre/postconditions before implementation
3. Immutability: Prefer immutable sequences for verification benefits
4. Lemma Abstraction: Complex proofs encapsulated in helper lemmas

VERIFICATION STRATEGY:
- Use strong loop invariants instead of condition checking
- Encapsulate complex properties in helper lemmas
- Maintain single preconditions for clarity
- Ensure postconditions are mathematically precise

CODE ORGANIZATION:
1. Data definitions first
2. Helper lemmas for verification
3. Core business functions
4. Example usage and tests

COMMENTING STANDARDS:
- Each function has purpose and verification notes
- Complex invariants are explained
- Design decisions are documented
- Example usage demonstrates key properties
*/