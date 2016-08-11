//
//  DetailTableViewCell.m
//  MYtinerary
//
//  Created by Sung Kim on 8/9/16.
//  Copyright © 2016 Sung Kim. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "NSManagedObject+ManagedContext.h"
#import "Record.h"
#import "AppDelegate.h"

@interface DetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;


@end

@implementation DetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

-(void)setDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss z"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *stringedDate = [dateFormatter stringFromDate:date];
    
    self.dateLabel.text = stringedDate;
}

-(void)setTitle:(NSString *)title {
    if (title) {
        self.titleLabel.text = title;
    }
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

//- (void)textFieldDidEndEditing:(UITextField *)textField {
  //  if ([self.titleLabel.text length] > 0) {
    //    self.comments = self.titleLabel.text;
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
//        UILabel *textField = [[UILabel alloc]init];
//        self.commentTextField = textField;
//        textField.text = comment;
        
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
//retreive



@end
