package com.example.owo.mamn01project.LetterRecognition;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;
 class MatchProcessor {

    private MatchProcessor() {}
    public static List<Letter> processMatch(String raw_match) {
        List<String> processed_match = Arrays.asList(raw_match.split(" "));

        processed_match = splitAcronyms(processed_match);
        processed_match = splitStickyUppercaseLetters(processed_match);
        processed_match = replaceHomophones(processed_match);
        processed_match = extractFirstLetters(processed_match);

        List<Letter> letters_list = processed_match.stream().map(Letter::fromString).collect(Collectors.toList());
        letters_list = letters_list.stream().filter(Objects::nonNull).collect(Collectors.toList());

        var final_result = letters_list;

        return final_result;
    }

    private static List<String> extractFirstLetters(List<String> processedMatch) {
        return processedMatch.stream()
                .map(s -> s.split("")[0])
                .collect(Collectors.toList());
    }

    /*
    *  Replace homophones such as "SAID" with "Z", "YAY", "J", etc.
    */
    private static List<String> replaceHomophones(List<String> processedMatch) {
        var clone = new ArrayList<>(processedMatch);
        clone.replaceAll(s -> {
            switch (s.toUpperCase()) {
                case "YOU":
                    return "U";
                case "YAY":
                    return "J";
                case "SAID":
                    return "Z";
                case "HEY":
                    return "H";
                default:
                    return s;
            }
        });
        return clone;
    }

    /*
    *  This function splits strings such as "ABC" and "JK" into letters.
    */
    private static List<String> splitStickyUppercaseLetters(List<String> list) {
        return list.stream()
                .flatMap(string -> {
                    var isSticky = string.equals(string.toUpperCase());
                    if(isSticky) {
                        return Arrays.stream(string.split(""));
                    } else {
                        return Stream.of(string);
                    }
                }).collect(Collectors.toList());
    }

    /*
    * Split acronyms. Such as "JK", "HTML", "pqr", "tqr".
     */
     private static List<String> splitAcronyms(List<String> list) {
         List<String> acronyms = Arrays.asList(
                 "JK",
                 "PQR",
                 "TQR",
                 "IMO",
                 "P.M.",
                 "OOP",
                 "NTL",
                 "HTTP",
                 "HTTPS",
                 "IAAS",
                 "ERP",
                 "ROI",
                 "PFP",
                 "PHD"
         );
            return list.stream()
                    .flatMap(string -> {
                        if (acronyms.contains(string.toUpperCase())) {
                            return Arrays.stream(string.toUpperCase().split(""));
                        } else {
                            return Stream.of(string);
                        }
                    }).collect(Collectors.toList());
     }
}