//
//  main.m
//  Rearrangement of 句变
//
//  Created by AnLuoRidge on 8/17/16.
//  Copyright © 2016 AnLuoRidge. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    
    // Set file path
    
    NSURL *baseURL = [NSURL fileURLWithPath:@"/Users/AnLuoRidge/"];
    NSURL *URL = [NSURL fileURLWithPath:@"TEMP/CKW Input.txt" relativeToURL:baseURL];
    NSError *error;
    
    // Read
    
    NSArray *stringsFromFileAtURL = [[[NSString alloc]
                                      initWithContentsOfURL:URL// [URL absoluteURL]
                                      encoding:NSUTF8StringEncoding// or NSUnicodeStringEncoding
                                      error:&error] componentsSeparatedByString:@"《时代の句变》"];
    
    // Separating each 句变
    // Save into arr_input (2D array)
    
    NSMutableArray *arr_input = [[NSMutableArray alloc] initWithCapacity:30];
    
    for (NSString *str in stringsFromFileAtURL) {
        [arr_input addObject:[str componentsSeparatedByString:@"\n"]];
    }
    
    // The first one is empty...
    
    [arr_input removeObjectAtIndex:0];
    
    NSMutableArray *arr_output = [[NSMutableArray alloc] initWithCapacity:30];
    
    for (NSArray *_entry in arr_input) {
        
        NSMutableArray *entry = [[NSMutableArray alloc] initWithArray:_entry];
        
        // remove empty line
        
        for (int i = 0; i<entry.count; i++) {
            
            if ([entry[i] length] <= 1) {
                [entry removeObjectAtIndex:i];
                i--; // detect the old place which has been replaced by new object
            }
        }
        
        // Reorder
        
        NSMutableArray *strsInOrder = [[NSMutableArray alloc] initWithCapacity:10];
        
        // TODO: searching to locate the right entry
        // TODO: split and retag the comment
        
        [strsInOrder addObject:entry[0]];// Time
        [strsInOrder addObject:entry[1]];// News
        [strsInOrder addObject:entry[7]];// Source
        [strsInOrder addObject:entry[2]];// trans1
        [strsInOrder addObject:entry[3]];// trans2
        [strsInOrder addObject:entry[5]];// word
        [strsInOrder addObject:entry[6]];// explaination
        [strsInOrder addObject:entry[4]];// comment (trans)
        [strsInOrder addObject:entry[8]];// copyright1
        [strsInOrder addObject:entry[9]];// copyright2
        
        [entry removeAllObjects];// release
        
        // Time -> [Time]
        
        strsInOrder[0] = [@"["  stringByAppendingString:strsInOrder[0]];
        strsInOrder[0] = [strsInOrder[0] stringByAppendingString:@"] "];
        //[strsInOrder[0] appendString:@"] "]; is used for NSMutableString
        
        // News
        
        strsInOrder[1] = [strsInOrder[1] stringByReplacingOccurrencesOfString:@"【事】" withString:@""];
        
        // Source -> [Source]
        
        strsInOrder[2] = [strsInOrder[2] stringByReplacingOccurrencesOfString:@"【源】" withString:@" ["];
        // del space
        strsInOrder[2] = [strsInOrder[2] stringByReplacingOccurrencesOfString:@" " withString:@""];
        [strsInOrder[2] appendString:@"]"];
        // set text to gray
        strsInOrder[2] = [@"<font color =\"#8c8c8c\">" stringByAppendingString:strsInOrder[2]];
        strsInOrder[2] = [strsInOrder[2] stringByAppendingString:@"</font>"];
        
        // Translations
        
        for (int i = 3 ; i< 5; ++i) {
            
            strsInOrder[i] = [strsInOrder[i] stringByReplacingOccurrencesOfString:@"［译］" withString:@""];
            //bold
            strsInOrder[i] = [@"<b>" stringByAppendingString:strsInOrder[i]];
            strsInOrder[i] = [strsInOrder[i] stringByReplacingOccurrencesOfString:@"：" withString:@"：</b>"];
        }
        
        // Word
        
        strsInOrder[5] = [strsInOrder[5] stringByReplacingOccurrencesOfString:@"【辞】" withString:@""];
        [strsInOrder[5] appendString:@"："];
        strsInOrder[6] = [strsInOrder[6] stringByReplacingOccurrencesOfString:@"［义］" withString:@""];
        
        // Comment
        
        strsInOrder[7] = [strsInOrder[7] stringByReplacingOccurrencesOfString:@"［评］" withString:@""];
        strsInOrder[7] = [@"<b>" stringByAppendingString:strsInOrder[7]];
        strsInOrder[7] = [strsInOrder[7] stringByReplacingOccurrencesOfString:@"：" withString:@"：</b>"];
        
        // Join each part
        
            // Part1: Times+News+Source
        
        NSString *news = [strsInOrder[0] stringByAppendingString:strsInOrder[1]];
        news = [news stringByAppendingString:strsInOrder[2]];

            // Part2: Translation 1+2
        
        NSString *translations = [strsInOrder[3] stringByAppendingString:@"<br>"];
        translations = [translations stringByAppendingString:strsInOrder[4]];
        
            // Part3: Word+Explaination
        
        NSString *word = [strsInOrder[5] stringByAppendingString:strsInOrder[6]];
        
        
            // Part4: Comment
        
        NSString *comment = strsInOrder[7];
        
            // Part5: Copyright
        
        NSString *copyright = [strsInOrder[8] stringByAppendingString:@"<br>"];
        copyright = [copyright stringByAppendingString:strsInOrder[9]];
        
        // Join 1-5

        entry = [[NSMutableArray alloc]initWithObjects:news, translations, word, comment, copyright, nil];
        
        [arr_output addObject: [entry componentsJoinedByString:@"\t"]];
    }
    
    // Join all entries
    
    NSString *output = [arr_output componentsJoinedByString:@"\n"];
    
    // write to file
    
    NSURL *baseOutputURL = [NSURL fileURLWithPath:@"/Users/AnLuoRidge/"];
    NSURL *outputURL = [NSURL fileURLWithPath:@"TEMP/CKW Output.txt" relativeToURL:baseOutputURL];
    
    @try {
        [output writeToURL:outputURL atomically:NO
                  encoding:NSUTF8StringEncoding error:&error];
    } @catch (NSException *exception) {
        NSLog(@"Error writing file at %@\n%@",
              URL, [error localizedFailureReason]);
    } @finally {
        NSLog(@"%@", output);
    }
    
    
    return 0;
}
