//
//  FlexLanguageTextField.h
//  Conjugate
//
//  Created by Halil Gursoy on 31/10/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

// Solution taken from the following stackoverflow answer: http://stackoverflow.com/questions/12595970/iphone-change-keyboard-language-programmatically

#ifndef FlexLanguageTextField_h
#define FlexLanguageTextField_h


#import <UIKit/UIKit.h>


@interface FlexLanguageTextField : UITextField

@property (strong, nonatomic) NSString *locale;

@end


#endif /* FlexLanguageTextField_h */
