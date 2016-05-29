//
//  FirstViewController.m
//  Conjugate
//
//  Created by Adel  Shehadeh on 5/29/16.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

#define CONJUGATOR_BASE_URL 20



@implementation FirstViewController


#ifdef DEBUG
NSString *const conjugatorBaseEndPoint = @"http://api.verbix.com/conjugator/json/eba16c29-e22e-11e5-be88-00089be4dcbc/deu/";
#else
NSString *const conjugatorBaseEndPoint = "http://api.verbix.com/conjugator/json/eba16c29-e22e-11e5-be88-00089be4dcbc/deu/";
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    self.verbUITextField.delegate = self;
    
    
    
    
}



- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string{
    
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSLog(@"Word typed 1 = %@", newString);
    //start fitching stuff
    [self fetchDataWithString:newString];
    
    return YES;
}

- (void) fetchDataWithString:(NSString *)string{
    
    //stich the typed word to the base URL and encode in case there's some weird characters.
    NSURL *url = [[NSURL alloc] initWithString:[ [conjugatorBaseEndPoint stringByAppendingString:string]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    
    //NSString *newCountryString =[@"fdd" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    
    
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
                NSLog(@"Data %@", returnedDict);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.jsonResultsTextView.text =returnedDict.description;

                });
                
                
                
            }
            
            
        }
    }];
    
    // Resume the task.
    [task resume];
    
    
}


@end
