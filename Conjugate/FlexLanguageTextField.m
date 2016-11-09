//
//  FlexLanguageTextField.m
//  Conjugate
//
//  Created by Halil Gursoy on 31/10/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

#import "FlexLanguageTextField.h"


@implementation FlexLanguageTextField

- (UITextInputMode *) textInputMode {
    for (UITextInputMode *tim in [UITextInputMode activeInputModes]) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        if ([[FlexLanguageTextField langFromLocale:_locale] isEqualToString:[FlexLanguageTextField langFromLocale:tim.primaryLanguage]])
            self.autocorrectionType = UITextAutocorrectionTypeYes;
            return tim;
    }
    return [super textInputMode];
}

+ (NSString *)langFromLocale:(NSString *)locale {
    NSRange r = [locale rangeOfString:@"_"];
    if (r.length == 0) r.location = locale.length;
    NSRange r2 = [locale rangeOfString:@"-"];
    if (r2.length == 0) r2.location = locale.length;
    return [[locale substringToIndex:MIN(r.location, r2.location)] lowercaseString];
}

@end
