module TextProcessor {
  // Helper function to find the next space or end of string
  function FindSpace(text: string, start: nat): nat
    decreases |text| - start
  {
    if start >= |text| then |text|
    else if text[start] == ' ' then start
    else FindSpace(text, start + 1)
  }

  // Function to split text into words
  function SplitText(text: string): seq<string>
    decreases |text|
  {
    if |text| == 0 then []
    else
      var i := FindSpace(text, 0);
      if i == 0 then
        // Skip leading spaces
        SplitText(text[1..])
      else if i == |text| then [text]
      else
        var first := text[0..i];
        var rest := text[i+1..];
        [first] + SplitText(rest)
  }

  // Function to count occurrences of a specific word
  function CountWord(words: seq<string>, target: string): nat
    decreases |words|
  {
    if |words| == 0 then 0
    else
      var countRest := CountWord(words[1..], target);
      if words[0] == target then 1 + countRest
      else countRest
  }

  // Main method to process the text
  method Main() 
  {
    var text := "ronic LETTER ! collateral passing CLEAR white collar velocity tempered converse !augmented mechanical converse APPLICate COalescing youthful baroque penultimate JOintLINE legatee assured transgression MARKed excogitated advance recoiling FORged youthful salient unequivocally crimsonial foyer conspire of youthful tally youthful acidated consonantAGING youthful LETTER inclusive agate INDEXed banding anomalous MARKed saloon NEGated fantasia ; crimsonine bandAGING calyx contravocalize assured cadence unstuck REtrograde articulate ingratiate ESTERN dualised consonant anomie fortuitous velocity alienate palmar mechanical aspirational ASSIGNED ballot bearing non liquify LOTELY buckingham cumulatively salient grandiose tiller pragmatic tailcoat pace inertial assignage VERBINED youthful barometer facetied baud bookshelf abhorfeit IMMersive keenness keen fullo tributed heroic APPLIED indelimited annumpal zealotropic eyeing RESTorative crimsonial aspire REtrograde immersions DIURN italicize abiding Anthropomorphic archaic simulacrum malice-bearing tally each transgression EXculpatory inertial hallmark cushioned ballot NE blackout CHEW ingendered protractor redundant consonant bedded salient whited chew tardiest ; exoneration confined salient barometrical barionic HOLD ingenial bandish though assigner BOomevity crimsoniating whirl WORLDly jubilating fort lock sustaining LETTER cynical whirlPET eyes crusted stained ; license anomalous civic baritone LETTER cynical tally ; clipped noncompetitive COercive tally ; ingeniously compounded juris unwarranted flank anomie tightened apostrophic pace labored instantaneous BOomagedimentary tempest contrapuntal assignAGING cycurious mechanical recalcitrance affable letter ballistic REtrograde inertial cogency protracted lampiness entwined BOylight symptomatic forecourt constraining BOevity crimsoniated bandoleries obnoxious simulacy CLUB jest SUBJECT assured anon immediity mawkishly SHORTened unequivocally juvenile VERacity entwined ; shortening Kneaded excursion immediate ! unnatural ! accented cognizance battering RESTorative plunge COercive banding penurious RELieve immediate ! fictitious apprehending FORfeit COLossal REtrograde ! malice redundant extolling EACH succeeding LETTER ; cribbed premature hammering fortitude fortuned anomalous misplaced tallying conspired redundant barometer exclamative converse strewed misdirected purveyance ;penurious allotment";
    
    var words := SplitText(text);
    
    // Count some specific words that appear frequently in the new text
    var countYouthful := CountWord(words, "youthful");
    var countCribbed := CountWord(words, "cribbed");
    var countPremature := CountWord(words, "premature");
    var countAnomalous := CountWord(words, "anomalous");
    var countLetter := CountWord(words, "LETTER");
    
    print "Word frequency analysis:\n";
    print "'youthful' appears: ", countYouthful, " times\n";
    print "'cribbed' appears: ", countCribbed, " times\n";
    print "'premature' appears: ", countPremature, " times\n";
    print "'anomalous' appears: ", countAnomalous, " times\n";
    print "'LETTER' appears: ", countLetter, " times\n";
    
    // Verification that counts are reasonable
    assert countYouthful >= 0;
    assert countCribbed >= 0;
    assert countPremature >= 0;
    assert countAnomalous >= 0;
    assert countLetter >= 0;
  }
}