//
//  FirstViewController.h
//  Conjugate
//
//  Created by Adel  Shehadeh on 5/29/16.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *verbUITextField;
@property (weak, nonatomic) IBOutlet UITextView *jsonResultsTextView;

- (void) conjugteWithString:(NSString *)string;
- (NSString *) searchVerbFormWithString:(NSString *)string;

@end

