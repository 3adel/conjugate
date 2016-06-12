//
//  FirstViewController.h
//  Conjugate
//
//  Created by Adel  Shehadeh on 5/29/16.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource>



//outlets
@property (weak, nonatomic) IBOutlet UITableView *conjugationsTableView;


@property (weak, nonatomic) IBOutlet UITextField *verbUITextField;
@property (weak, nonatomic) IBOutlet UITextView *jsonResultsTextView;
@property (strong, nonatomic) UITapGestureRecognizer *tapToDismissKeyboard;
@property (strong, nonatomic) UIPanGestureRecognizer *panToDismissKeyboard;
@property (weak, nonatomic) IBOutlet UITextView *conjugationResultsUITableView;



@property (strong, nonatomic) NSMutableDictionary *sectionedConjugations;
@property (weak, nonatomic) NSArray *conjugationSectionTitlesArray;


- (void) conjugteWithString:(NSString *)string;
- (NSString *) searchVerbFormWithString:(NSString *)string;
-(void)dismissKeyboard;
@end

