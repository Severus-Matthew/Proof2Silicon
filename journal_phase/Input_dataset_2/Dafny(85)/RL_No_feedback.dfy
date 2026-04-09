module CardVerification {
  
  class Card {
    var digits: array<int>
    
    constructor(digits': array<int>)
      requires digits'.Length > 0
    {
      digits := digits';
    }
    
    method calculateCheckDigit() returns (checkDigit: int)
      ensures 0 <= checkDigit && checkDigit <= 9
    {
      // Handle case where array has only 1 digit
      if digits.Length == 1 {
        // For single digit, the check digit is calculated such that
        // the digit itself becomes valid when appended with check digit
        var sum: int := 0;
        var alternate: bool := true; // Start with alternate true since we're processing from right
        var digit: int := digits[0];
        
        if alternate {
          digit := digit * 2;
          if digit > 9 {
            digit := digit - 9;
          }
        }
        
        sum := sum + digit;
        checkDigit := (10 - (sum % 10)) % 10;
        return;
      }
      
      var sum: int := 0;
      var alternate: bool := false;
      
      // Start from the rightmost digit (excluding check digit)
      var i: int := digits.Length - 2;
      while i >= 0
        decreases i
      {
        var digit: int := digits[i];
        
        if alternate {
          digit := digit * 2;
          if digit > 9 {
            digit := digit - 9;
          }
        }
        
        sum := sum + digit;
        alternate := !alternate;
        i := i - 1;
      }
      
      checkDigit := (10 - (sum % 10)) % 10;
    }
    
    method isValid() returns (valid: bool)
    {
      if digits.Length == 0 {
        valid := false;
        return;
      }
      
      var sum: int := 0;
      var alternate: bool := false;
      
      // Start from the rightmost digit (including check digit)
      var i: int := digits.Length - 1;
      while i >= 0
        decreases i
      {
        var digit: int := digits[i];
        
        if alternate {
          digit := digit * 2;
          if digit > 9 {
            digit := digit - 9;
          }
        }
        
        sum := sum + digit;
        alternate := !alternate;
        i := i - 1;
      }
      
      valid := sum % 10 == 0;
    }
  }
  
  method Main()
  {
    // Example: Valid card number 4242424242424242 (test Visa number)
    // Digits: [4,2,4,2,4,2,4,2,4,2,4,2,4,2,4,2] where last digit 2 is check digit
    var validCardDigits: array<int> := new int[16];
    validCardDigits[0] := 4; validCardDigits[1] := 2; validCardDigits[2] := 4; validCardDigits[3] := 2;
    validCardDigits[4] := 4; validCardDigits[5] := 2; validCardDigits[6] := 4; validCardDigits[7] := 2;
    validCardDigits[8] := 4; validCardDigits[9] := 2; validCardDigits[10] := 4; validCardDigits[11] := 2;
    validCardDigits[12] := 4; validCardDigits[13] := 2; validCardDigits[14] := 4; validCardDigits[15] := 2;
    
    var card1 := new Card(validCardDigits);
    var isValid1: bool := card1.isValid();
    print "Valid card test: ", isValid1, "\n";
    
    // Example: Invalid card number (changed last digit)
    var invalidCardDigits: array<int> := new int[16];
    invalidCardDigits[0] := 4; invalidCardDigits[1] := 2; invalidCardDigits[2] := 4; invalidCardDigits[3] := 2;
    invalidCardDigits[4] := 4; invalidCardDigits[5] := 2; invalidCardDigits[6] := 4; invalidCardDigits[7] := 2;
    invalidCardDigits[8] := 4; invalidCardDigits[9] := 2; invalidCardDigits[10] := 4; invalidCardDigits[11] := 2;
    invalidCardDigits[12] := 4; invalidCardDigits[13] := 2; invalidCardDigits[14] := 4; invalidCardDigits[15] := 1;
    
    var card2 := new Card(invalidCardDigits);
    var isValid2: bool := card2.isValid();
    print "Invalid card test: ", isValid2, "\n";
    
    // Test calculateCheckDigit method
    var checkDigit: int := card1.calculateCheckDigit();
    print "Check digit for valid card: ", checkDigit, "\n";
    
    // Additional test: calculate check digit for invalid card
    var checkDigit2: int := card2.calculateCheckDigit();
    print "Check digit for invalid card: ", checkDigit2, "\n";
    print "Expected check digit (should be 2): ", checkDigit2, "\n";
    
    // Test edge case: single digit card
    var singleDigitArray: array<int> := new int[1];
    singleDigitArray[0] := 5;
    var card3 := new Card(singleDigitArray);
    var checkDigit3: int := card3.calculateCheckDigit();
    print "Check digit for single digit card: ", checkDigit3, "\n";
    
    // Test if single digit with calculated check digit becomes valid
    var singleDigitWithCheck: array<int> := new int[2];
    singleDigitWithCheck[0] := 5;
    singleDigitWithCheck[1] := checkDigit3;
    var card4 := new Card(singleDigitWithCheck);
    var isValid4: bool := card4.isValid();
    print "Single digit with check digit is valid: ", isValid4, "\n";
  }
}