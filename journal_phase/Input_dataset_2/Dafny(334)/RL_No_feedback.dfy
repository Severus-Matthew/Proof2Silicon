module Main {
  method Main() {
    var input := "SHORT atomLeg snug wis dangling bare deliberate remix snap stab MoralRing personal JSfirst SINGLE duptem drib rag twin gemsm excl labAPO Atom localknow welt gratuit SINGLE snugno genu kindly atom capped dribSJ nightly prep:<? JSeveryAnth best :-DIV few snug crack dup inert --pl genu erot weakest silver anon duplastexas ALT each quartbare polish ironleast dom botsimplewis:<?desired Quest embr compreh atom Apex tight pre lint fores biz wur boot cheapest testgold dup snugAPO mine Pussy domest snug rubJR dark NYC sole only dupbane reflex sw anarch core legit domestnear timedSw fam jade\"spen for engagingPy dum trusted PG alloy Bline OPENgodshal core lust anon wur toll predatory abdom erot biz vit predsnowAH assort blo dangling sam wellSX genu'C _.each fridaySX Conc kosher dive anon ah fast anon#:torCos dom Depth wann hust Linearsal VOL littMis dizzy core REscar econom snug *.toy paused ALL Autom Validembr predatory blank snug ;cash dupAutom\"<?every coder hob precise vag excl dark domest doll 'hack:<?last Static testembr Conc pro dailystab minAFF ener civicClub ;muchlast Apex silver amat premature Ent High riv dup leg vanilla#:each Local PresCAL absor trustedsqu bare*D bounty every blohal maint jail autob genu #:god thoughtful mystery dup drib erotJ erot#:each RderSoft dup:ImeldCy\"Flocal no Cong core bizCy|\"ideal monthly freextoy promisetoy genu\"sletter\"s anticipated Q pref[L CL finely simul die cr﹩no#:everyfig#:bw remix ~GoldAs st weekly,V🌿toy wur lab amat wann\"sLate snug techUpper ($below lab spankingSX rare yrbane max vit atomembr:<?passed truth yr automatedtouch securejud function partial eye youthful main Ind mismeld💛native bizclosure glad Com Macro Comp tally snug domest enclosed atom ~mel cheek biz Depth vapor subtoyFast sag satur Club labAPO yournegAFF fortune Co ✔latest recru lab comp crunch FA sterlinganon bloAPO prebane manufact ment awesomeCos.,echo wis:<?anon coder security bare free drib blo self Narrow Elect drib pred legit pear drib#:corp anthlast fig erot wur techshr vexsunsexy #J truth sterling legal unn superbmeldswAFF Cross liqu model Ent bizCywh dom dupstraight kindly Nuclear plug snugsus ne core bio virgin selfie laxSan domAFF Defensive till Conc dimAPO tillAH Fsweach#:corp neCos low Gluten Alien brand gent simul%! Pres narrowing,Vgov three GTX erot !\"Fox dupsing nett pall declar wursw vet%'qualified testdro dual VC wann";
    
    // Count occurrences of specific patterns
    var singleCount := CountOccurrences(input, "SINGLE");
    var hashColonCount := CountOccurrences(input, "#:");
    var questionColonCount := CountOccurrences(input, ":<?");
    var snugCount := CountOccurrences(input, "snug");
    var atomCount := CountOccurrences(input, "atom");
    var erotCount := CountOccurrences(input, "erot");
    
    print "Pattern Analysis:\n";
    print "SINGLE occurrences: ", singleCount, "\n";
    print "#: occurrences: ", hashColonCount, "\n";
    print ":<? occurrences: ", questionColonCount, "\n";
    print "'snug' occurrences: ", snugCount, "\n";
    print "'atom' occurrences: ", atomCount, "\n";
    print "'erot' occurrences: ", erotCount, "\n";
    print "\n";
    
    // Extract sections between :<? delimiters
    var sections := ExtractSectionsBetweenDelimiters(input, ":<?");
    print "Sections between :<? delimiters:\n";
    var i := 0;
    while i < |sections|
      invariant 0 <= i <= |sections|
    {
      print "Section ", i + 1, ": ", sections[i], "\n";
      i := i + 1;
    }
    print "\n";
    
    // Extract sections between #: delimiters
    var hashSections := ExtractSectionsBetweenDelimiters(input, "#:");
    print "Sections between #: delimiters:\n";
    i := 0;
    while i < |hashSections|
      invariant 0 <= i <= |hashSections|
    {
      print "Section ", i + 1, ": ", hashSections[i], "\n";
      i := i + 1;
    }
  }
  
  method CountOccurrences(s: string, pattern: string) returns (count: int)
    ensures count >= 0
  {
    count := 0;
    var i := 0;
    
    // Handle case where pattern is longer than the string
    if |pattern| > |s| {
      return;
    }
    
    while i <= |s| - |pattern|
      invariant 0 <= i <= |s|
      invariant count >= 0
    {
      if s[i..i+|pattern|] == pattern {
        count := count + 1;
        i := i + |pattern|;  // Skip the entire pattern length
      } else {
        i := i + 1;
      }
    }
  }
  
  method ExtractSectionsBetweenDelimiters(s: string, delimiter: string) returns (sections: seq<string>)
    ensures |sections| >= 0
  {
    sections := [];
    var start := 0;
    var i := 0;
    var foundFirst := false;
    
    while i < |s|
      invariant 0 <= i <= |s|
      invariant start >= 0 && start <= i
    {
      if i <= |s| - |delimiter| && s[i..i+|delimiter|] == delimiter {
        if foundFirst {
          // Found second delimiter, extract section between them
          sections := sections + [s[start..i]];
          start := i + |delimiter|;
        } else {
          // Found first delimiter
          foundFirst := true;
          start := i + |delimiter|;
        }
        i := i + |delimiter|;
      } else {
        i := i + 1;
      }
    }
    
    // If we found a first delimiter but no closing one, add the remaining section
    if foundFirst && start < |s| {
      sections := sections + [s[start..|s|]];
    }
  }
}