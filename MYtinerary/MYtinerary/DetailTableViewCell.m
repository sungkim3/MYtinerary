//
//  DetailTableViewCell.m
//  MYtinerary
//
//  Created by Sung Kim on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "NSManagedObject+ManagedContext.h"

@interface DetailTableViewCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@end

@implementation DetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.commentTextField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setImage:(UIImage *)image {
    _image = image;
    self.imgView.image = image;
}

-(void)setDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"EEE, d MMM yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *stringedDate = [dateFormatter stringFromDate:date];
    
    self.dateLabel.text = stringedDate;
}

-(void)setComments:(NSString *)comments {
    _comments = comments;
    self.commentTextField.text = comments;
    self.commentTextField.clearsOnBeginEditing = NO;
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [overlayButton addTarget:self action:@selector(saveContext:) forControlEvents:UIControlEventTouchUpInside];
    self.commentTextField.rightView = overlayButton;
    self.commentTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setCommentTextField:(UITextField *)commentTextField
{
    _commentTextField = commentTextField;
    _commentTextField.text = self.record.comments;
}

- (void)saveContext:(UIButton *)sender
{
    NSLog(@"Save button pressed");
    
    if ([self.commentTextField.text length] > 0) {
        NSString *comment = self.commentTextField.text;
        
        NSLog(@"%@", comment);
        
        [self.record setValue:comment forKey:@"comments"];
        
        NSError *saveError;
        BOOL isSaved = [[NSManagedObject managedContext] save:&saveError];
        if(isSaved) {
            NSLog(@"Comment saved successfully. Comment it: %@", self.record.comments);
        } else {
            NSLog(@"Unsuccessful save of comment: %@", saveError.localizedDescription);
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
