module Main {
  method parseAndTransform(input: string) returns (result: string)
    ensures result != ""
  {
    var i := 0;
    var output := "";
    var currentWord := "";
    var inWord := false;
    
    while i < |input|
      invariant 0 <= i <= |input|
      invariant output != null
      invariant currentWord != null
    {
      var ch := input[i];
      
      // Check for uppercase letter indicating start of a new component
      if ('A' as int <= ch as int && ch as int <= 'Z' as int) && !inWord {
        if currentWord != "" then {
          output := output + transformWord(currentWord) + " ";
          currentWord := "";
        }
        inWord := true;
        currentWord := currentWord + [ch];
      }
      else if ('a' as int <= ch as int && ch as int <= 'z' as int) && inWord {
        currentWord := currentWord + [ch];
      }
      else {
        // Handle transition between words
        if currentWord != "" then {
          output := output + transformWord(currentWord) + " ";
          currentWord := "";
        }
        inWord := false;
      }
      
      i := i + 1;
    }
    
    // Process the last word if any
    if currentWord != "" then {
      output := output + transformWord(currentWord);
    }
    
    result := output;
  }
  
  function transformWord(word: string): string
    requires word != ""
  {
    var transformed := "";
    
    // Check for specific prefixes and apply transformations
    if startsWith(word, "Cos") then {
      transformed := "Cosmic" + extractAfter(word, "Cos");
    }
    else if startsWith(word, "Neon") then {
      transformed := "Neon" + extractAfter(word, "Neon");
    }
    else if startsWith(word, "sole") then {
      transformed := "Sole" + extractAfter(word, "sole");
    }
    else if startsWith(word, "pal") then {
      transformed := "Pal" + extractAfter(word, "pal");
    }
    else if startsWith(word, "trib") then {
      transformed := "Tribal" + extractAfter(word, "trib");
    }
    else if startsWith(word, "atomic") then {
      transformed := "Atomic" + extractAfter(word, "atomic");
    }
    else if startsWith(word, "Void") then {
      transformed := "Void" + extractAfter(word, "Void");
    }
    else if startsWith(word, "Global") then {
      transformed := "Global" + extractAfter(word, "Global");
    }
    else if startsWith(word, "Prime") then {
      transformed := "Prime" + extractAfter(word, "Prime");
    }
    else if startsWith(word, "Ultimate") then {
      transformed := "Ultimate" + extractAfter(word, "Ultimate");
    }
    else if startsWith(word, "ultimate") then {
      transformed := "Ultimate" + extractAfter(word, "ultimate");
    }
    else {
      // Capitalize first letter for other words
      transformed := capitalize(word);
    }
    
    // Apply suffix transformations
    if endsWith(transformed, "boxed") then {
      transformed := removeSuffix(transformed, "boxed") + "Box";
    }
    else if endsWith(transformed, "ded") then {
      transformed := removeSuffix(transformed, "ded") + "ed";
    }
    else if endsWith(transformed, "ious") then {
      transformed := removeSuffix(transformed, "ious") + "ious";
    }
    else if endsWith(transformed, "acious") then {
      transformed := removeSuffix(transformed, "acious") + "acious";
    }
    else if endsWith(transformed, "anted") then {
      transformed := removeSuffix(transformed, "anted") + "anted";
    }
    
    return transformed;
  }
  
  function startsWith(s: string, prefix: string): bool
    requires prefix != ""
  {
    if |s| < |prefix| then false
    else s[0..|prefix|] == prefix
  }
  
  function endsWith(s: string, suffix: string): bool
    requires suffix != ""
  {
    if |s| < |suffix| then false
    else s[|s|-|suffix|..] == suffix
  }
  
  function extractAfter(s: string, prefix: string): string
    requires startsWith(s, prefix)
  {
    s[|prefix|..]
  }
  
  function removeSuffix(s: string, suffix: string): string
    requires endsWith(s, suffix)
  {
    s[0..|s|-|suffix|]
  }
  
  function capitalize(s: string): string
    requires s != ""
  {
    var first := s[0];
    var rest := s[1..];
    
    if 'a' as int <= first as int && first as int <= 'z' as int then {
      var upperFirst := charToUpper(first);
      [upperFirst] + rest
    } else {
      s
    }
  }
  
  function charToUpper(ch: char): char
  {
    if 'a' as int <= ch as int && ch as int <= 'z' as int then
      (ch as int - ('a' as int - 'A' as int)) as char
    else
      ch
  }
  
  method Main() {
    var input := "Concognominably pristine Automatedpalacious pallacious Global immature remixboxed ign anomtern swpatomic reflective decatomic bridswsingUbith genuvoy redundant Neonsole conscegis genuapheneCosexualsquacious coreswanted soleprox intimate excludedsquacious solepalrogtribal redundantMasterpalveboxed affirmbarestro mirroredlastsquaintswantedsquineultimate Jbelucid abdedtribacyCosexual confineCognanted cheekpalitysilverboxed redundantPremsoleCos lowsquodminimal atomic rotsolepassionate dupsole penetracyVoidboxed inertalienpalisticCosniteconcncy anonDIegis supreme decegis vital cribtoy granddom wholwarve embrself agstabswanted NeonCos sentient lastIter inertestlastsanternsan abrasominacious inerttribniteDominated tribbedAPO cyclic equanted GlobalVoidpassevitymicrobarestabvariably ignantedleastboxedoblinedsquine soleclantedsquaciousswpedjudacious vegpalanguanted anaVoidswcomdedminimal atomicstab cycevitysquinegranternsolevoydedCosgodsoleCosembrined solejudaciouspentrolldated obsoleveboxedCoslate concembrine metast inert maltribtribpedbial obpalacious vitanguousassignlastsquineboxed Waxself jewself mirroredsolecharanguanted antsoleCosdompie nearpenacioussquallestsusculaciousPrime Tendersanaciouspure crustboxed Legcumsole delicate swextempedine apprentlysquest inertboxedPrime swexshrantedAnalMech inerttribdedsquatronsolesquacioussquale mirrored GlobalCossoleCosalienembrantedsuscept NeonpeddedsolebareboxedstepholmisclaaciouscyclniteCosprophazardfallded silvernestestbowstabsole limpCospenacious bayboxed Neon atomicCoscumtribdedCoswhonestpalacioussquatronsolesquanguineUbinevariablyembracious bourdedCosprehominacyboxed concalienvorative wheelCosprommisculantedultimate recaptribded jadeCosabointed penultimate Atomicline Neon orthtribdedjudacityboxed apoCosembrantedCosculamel agdedNegaciousrubacioussolepie dualboxedsquaciousnormtribalienchroniousAvg erotantedsolejudaciousculative remixbane Neonswded concinementCosdiestersoleprovincialdomtribdedwhanted anonbinary swternantedCosdomdedmise brilliouslastsquanc erotpedvariably genuvecumport cribalien obsoleveelectric liqu erotaciouslastsquaintalienpalaciousPrime labvariably NeonbaneCosmeld claavic cynicalsolewhanted supremeOuterpro";
    
    var result := parseAndTransform(input);
    print result;
  }
}