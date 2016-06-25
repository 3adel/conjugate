//
//  FirstViewController.m
//  Conjugate
//
//  Created by Adel  Shehadeh on 5/29/16.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController (){
    NSString *verbAPISearchResult;
    
        NSArray *conjugationSectionTitles;
    }

@end

#define CONJUGATOR_BASE_URL 20


@implementation FirstViewController

@synthesize conjugationResultsUITableView = _conjugationResultsUITableView;
#ifdef DEBUG
NSString *const conjugatorBaseEndPoint = @"http://api.verbix.com/conjugator/json/eba16c29-e22e-11e5-be88-00089be4dcbc/deu/";
NSString *const searchBaseEndPoint = @"http://api.verbix.com/finder/json/eba16c29-e22e-11e5-be88-00089be4dcbc/deu/";
#else
NSString *const conjugatorBaseEndPoint = "http://api.verbix.com/conjugator/json/eba16c29-e22e-11e5-be88-00089be4dcbc/deu/";
NSString *const searchBaseEndPoint = @"http://api.verbix.com/finder/json/eba16c29-e22e-11e5-be88-00089be4dcbc/deu/";
#endif

@synthesize tapToDismissKeyboard = _tapToDismissKeyboard;
@synthesize panToDismissKeyboard = _panToDismissKeyboard;
@synthesize conjugationSectionTitlesArray =_conjugationSectionTitlesArray;
@synthesize conjugationsTableView = _conjugationsTableView;
@synthesize sectionedConjugations =_sectionedConjugations;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.verbUITextField.delegate = self;
    self.conjugationsTableView.delegate = self;
    
    
    _tapToDismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    _panToDismissKeyboard =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:_tapToDismissKeyboard];
    
    
}



- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string{
    
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSLog(@"Word typed 1 = %@", newString);
    
    //start fitching stuff
    [self searchVerbFormWithString:newString];
    return YES;
}

//search the verb form
- (NSString *) searchVerbFormWithString:(NSString *)string{
    
    verbAPISearchResult = [[NSString alloc] init];

    //convert string to lower case. an API limitation
    NSString *lowerCaseString =[string lowercaseString];
    
    //stich the typed word to the base URL and encode in case there's some weird characters.
    NSURL *url = [[NSURL alloc] initWithString:[ [searchBaseEndPoint stringByAppendingString:lowerCaseString]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    NSLog(@"URL =%@ ",[searchBaseEndPoint stringByAppendingString:lowerCaseString]);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Create a data task object to perform the data downloading.
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            // If any error occurs then just display its description on the console.
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            if (HTTPStatusCode != 200) {
                NSLog(@"HTTP status code = %ld", (long)HTTPStatusCode);
            }
            
            else{
                
                NSArray *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                
                //Data successfully received
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //A proper verb is found
                    if (returnedDict.count >0) {
                        NSLog(@"Pure verb = %@", [returnedDict objectAtIndex:0]);
                        verbAPISearchResult =[[returnedDict objectAtIndex:0]description];
                        
                        //now pull the dictionary and find the root verb. .
                        self.jsonResultsTextView.text =[[returnedDict objectAtIndex:0] valueForKey:@"verb"];
                        
                        //not take the search result and call the conjugator
                        [self conjugteWithString:[[returnedDict objectAtIndex:0] valueForKey:@"verb"]];
                        
                        
                    }
                    
                });
                
            }
        }
    }];
    // Resume the task.
    [task resume];
    return nil;
}




//conjugate verb and update UI
- (void) conjugteWithString:(NSString *)string{
    
    //stich the typed word to the base URL and encode in case there's some weird characters.
    NSURL *url = [[NSURL alloc] initWithString:[ [conjugatorBaseEndPoint stringByAppendingString:string]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    NSLog(@"URL =%@ ",[conjugatorBaseEndPoint stringByAppendingString:string]);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Create a data task object to perform the data downloading.
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            // If any error occurs then just display its description on the console.
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            if (HTTPStatusCode != 200) {
                NSLog(@"HTTP status code = %ld", (long)HTTPStatusCode);
            }
            
            else{
                
                NSArray *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                
                //Data successfully received
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    //set sectioned conjugations
                    /*
                    _sectionedConjugations = @{@"B" : @[@"Bear", @"Black Swan", @"Buffalo"],
                                @"C" : @[@"Camel", @"Cockatoo"],
                                @"D" : @[@"Dog", @"Donkey"],
                                @"E" : @[@"Emu"],
                                @"G" : @[@"Giraffe", @"Greater Rhea"],
                                @"H" : @[@"Hippopotamus", @"Horse"],
                                @"K" : @[@"Koala"],
                                @"L"  : @[@"Lion", @"Llama"],
                                @"M" : @[@"Manatus", @"Meerkat"],
                                @"P" : @[@"Pandaaa", @"Peacock", @"Pig", @"Platypus", @"Polar Bear"],
                                @"R" : @[@"Rhinoceros"],
                                @"S" : @[@"Seagull"],
                                @"T" : @[@"Tasmania Devil"],
                                @"W" : @[@"Whale", @"Whale Shark", @"Wombat"]};
                    
                    conjugationSectionTitles = [[_sectionedConjugations allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                    [_conjugationsTableView reloadData];
                    */
                    _sectionedConjugations = [[NSMutableDictionary alloc] init];

                    for ( int i =0;i<=22;i++ ) {
  
                        //protect from nul
                        if ([[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",i]]valueForKey:@"forms"]) {
                            
                            
                            
                            
                            //set each section title
             
                            NSLog(@"%@ Type = %@",[NSString stringWithFormat:@"%d",i],[NSString stringWithFormat:@"%@",[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",i]]valueForKey:@"name"]] );
                            [_sectionedConjugations setObject:@"Object..." forKey:[NSString stringWithFormat:@"%@",[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",i]]valueForKey:@"name"]]];
                            
                            
                            [_conjugationsTableView reloadData];

                            
                            NSLog(@"%@", [[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",i]]valueForKey:@"name"]);
                            self.jsonResultsTextView.text = [self.jsonResultsTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n\n%@",[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",i]]valueForKey:@"name"]]];
                            self.jsonResultsTextView.text = [self.jsonResultsTextView.text stringByAppendingString:@"\n------------------------"];
                            
                            //count how many elements in "forms" for each row
                            for (int j=0; j<[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",i]]valueForKey:@"forms"]count]; j++) {
                                if ([[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"form"]) {
                                    
                                    //make sure that form and pronoun are both not null
                                    if ([[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"pronoun"]) {
                                        
                                        NSLog(@"%@: %@",[[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"pronoun"], [[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"form"]);
                                        
                                        
                                        self.jsonResultsTextView.text = [self.jsonResultsTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@: %@",[[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"pronoun"], [[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"form"]]];
                                        


                                    }
                                    
                                    else{
                                        NSLog(@"Form: %@", [[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"form"]);

                                        self.jsonResultsTextView.text = [self.jsonResultsTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", [[[[[returnedDict valueForKey:@"tenses"]valueForKey:[NSString stringWithFormat:@"%d",j]]valueForKey:@"forms"]objectAtIndex:j] valueForKey:@"form"]]];
                                        
                                    }
                                }
  
                            }
                            
                        }
  
                    }

                });

            }
 
        }
    }];
    
    // Resume the task.
    [task resume];
}



-(void)dismissKeyboard {
    [self.verbUITextField resignFirstResponder];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [conjugationSectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [conjugationSectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionTitle = [conjugationSectionTitles objectAtIndex:section];
    NSArray *sectionConjugations = [_sectionedConjugations objectForKey:sectionTitle];
    return [sectionConjugations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    // Configure the cell...
    NSString *sectionTitle = [conjugationSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionConjugations = [_sectionedConjugations objectForKey:sectionTitle];
    NSString *animal = [sectionConjugations objectAtIndex:indexPath.row];
    cell.textLabel.text = animal;
    
    return cell;
}



@end
