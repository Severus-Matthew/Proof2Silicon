method Main() {
  var input := "Autom strang pl hon adam wann min early atom atom intel boot nim brisk dup dup brill golden atom cr lab tally ag stagingVIN sterling rej anaanter juris trusted line excl dup sw pro wann J keen dual chargeCy yr budd ember AP aster pur civic sphere wur cal crimson electr brand mis dup testify SINGLE,/ genu sterling dup wis FM rub furnace drib snug lab brisk sm ember yr gover youthful ign erot fant fabulous biz dup arcane dup toll hubby wann dup sal wur sub legit oath erot vamp snug leap genu crimson dup snug test cash dup dup prox cal sne ne m fant lab cine dazz fast nuclear eye st st mis cookie wur wur yr remix biz atom dup xen real Afr dup JS dual wann fre drib jew lab erot jew anon ext JS all double pred trusted lust CH drib drib smart dont nit corner virus weir legit AB lif atomic wann deluxe ag ~AFF dup genu staple - wur homo metallic yr test drib sterling no mis thru ALL san legit cum global genu dup virgin dup amat ripeanon biz jew trusted fr wann,,,,where un drib sw anon erot drib jew bare lab male grip dup ~syn rom yr snug wur bounty cyc wis locked civic ap yr genu budd yr biz genu pred dec pir wann atom dark vol roy eer each fresh anomal dup anon crane atomic cost genu cash wur all pen dom browser brid budd sur afl st jew hand nightly JS mine atomic core sterling anon dup amat yr hom omin JS wann vere AP break neighborhood rej arch domest pen core yr budd anth fully dup cert oxidation adam duplicate prep wann juris sal cement yr jew genu betting mis wur cy fit wann snug ant open yr snug thoughtful dupline ag sne drib st port liqu friend L cy smart xen assembler dup dup fant lab atom genu wur cum wholly fresh dup app mis wur excl atomic yr ember jav voice core pl sam amo inert surve CR sal dup rub anom mag vex intel heart div neuro rub dup dup contrib rubDIV wann core yr jade arty wann yr fict domest cheap alien scor smart dup colleg civic dup minor san jade friday faux trusted noc legit sterling magic lab pl mantle wann wann wur dom wann WH wann facet rub drib bab wur sole crib predatory expect belly absor erot blo defensive cr well nau ste vamp gut vamp fig lab vern anti ember abras atomic hy genu assembler blo tech pro mand dup below trans electr legit mand Intl dev rub wur asia ferment monthly globe wann gold crim pron scar pull san bay legit dup dup fant biz wis fig pred rub juris minor cyc micro solo wis drib cosmic templ ath simul vocational scar crimson ground hubby cigar nightly qualifying narrow atom comm ember mis🌿 arty J wann vet glass arty assembler fre wur hubby genu extrav blo crib";
  
  var tokens := Split(input);
  var duplicates := FindDuplicates(tokens);
  var patterns := FindPatterns(tokens);
  
  print "Total tokens: ";
  print tokens.Length;
  print "\n";
  
  print "Duplicate words found: ";
  print duplicates.Length;
  print "\n";
  
  print "Most common patterns:\n";
  var i := 0;
  while i < patterns.Length && i < 5 {
    print patterns[i].0;
    print ": ";
    print patterns[i].1;
    print " times\n";
    i := i + 1;
  }
}

function Split(s: string): array<string>
  ensures |result| > 0
{
  var words := new string[0];
  var current := "";
  var i := 0;
  
  while i < |s| {
    var ch := s[i];
    if ch == ' ' || ch == ',' || ch == '.' || ch == '~' || ch == '-' || ch == '/' {
      if |current| > 0 {
        // Create new array for words
        var newSize := words.Length + 1;
        var newWords: array<string>;
        newWords := new string[newSize];
        var j := 0;
        while j < words.Length {
          newWords[j] := words[j];
          j := j + 1;
        }
        newWords[words.Length] := current;
        words := newWords;
        current := "";
      }
    } else {
      current := current + [ch];
    }
    i := i + 1;
  }
  
  if |current| > 0 {
    // Create new array for final word
    var newSize := words.Length + 1;
    var newWords: array<string>;
    newWords := new string[newSize];
    var j := 0;
    while j < words.Length {
      newWords[j] := words[j];
      j := j + 1;
    }
    newWords[words.Length] := current;
    words := newWords;
  }
  
  words
}

function FindDuplicates(tokens: array<string>): array<string>
{
  var duplicates := new string[0];
  var seen := new string[0];
  var i := 0;
  
  while i < tokens.Length {
    var token := tokens[i];
    var found := false;
    var j := 0;
    
    while j < seen.Length {
      if seen[j] == token {
        found := true;
        break;
      }
      j := j + 1;
    }
    
    if found {
      // Check if already in duplicates
      var alreadyAdded := false;
      var k := 0;
      while k < duplicates.Length {
        if duplicates[k] == token {
          alreadyAdded := true;
          break;
        }
        k := k + 1;
      }
      
      if !alreadyAdded {
        var newSize := duplicates.Length + 1;
        var newDuplicates: array<string>;
        newDuplicates := new string[newSize];
        var l := 0;
        while l < duplicates.Length {
          newDuplicates[l] := duplicates[l];
          l := l + 1;
        }
        newDuplicates[duplicates.Length] := token;
        duplicates := newDuplicates;
      }
    } else {
      var newSize := seen.Length + 1;
      var newSeen: array<string>;
      newSeen := new string[newSize];
      var m := 0;
      while m < seen.Length {
        newSeen[m] := seen[m];
        m := m + 1;
      }
      newSeen[seen.Length] := token;
      seen := newSeen;
    }
    
    i := i + 1;
  }
  
  duplicates
}

function FindPatterns(tokens: array<string>): array<(string, nat)>
{
  var patterns := new (string, nat)[0];
  var i := 0;
  
  while i < tokens.Length {
    if i + 1 < tokens.Length {
      var pattern := tokens[i] + " " + tokens[i + 1];
      var found := false;
      var j := 0;
      
      // Update count or add new pattern
      while j < patterns.Length {
        if patterns[j].0 == pattern {
          patterns[j].1 := patterns[j].1 + 1;
          found := true;
          break;
        }
        j := j + 1;
      }
      
      if !found {
        var newSize := patterns.Length + 1;
        var newPatterns: array<(string, nat)>;
        newPatterns := new (string, nat)[newSize];
        var k := 0;
        while k < patterns.Length {
          newPatterns[k] := patterns[k];
          k := k + 1;
        }
        newPatterns[patterns.Length] := (pattern, 1);
        patterns := newPatterns;
      }
    }
    i := i + 1;
  }
  
  // Sort patterns by frequency (simple bubble sort)
  var sorted := false;
  while !sorted {
    sorted := true;
    var k := 0;
    while k < patterns.Length - 1 {
      if patterns[k].1 < patterns[k + 1].1 {
        var temp := patterns[k];
        patterns[k] := patterns[k + 1];
        patterns[k + 1] := temp;
        sorted := false;
      }
      k := k + 1;
    }
  }
  
  patterns
}