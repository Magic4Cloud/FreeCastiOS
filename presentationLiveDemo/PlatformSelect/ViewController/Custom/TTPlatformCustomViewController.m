//
//  TTPlatformCustomViewController.m
//  presentationLiveDemo
//
//  Created by tc on 7/10/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTPlatformCustomViewController.h"
#import "TTCoreDataClass.h"

@interface TTPlatformCustomViewController ()<UITextFieldDelegate>
{
    CGFloat keyboardHeight;
}
@property (weak, nonatomic) IBOutlet UITextField *streamUrlTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *streamKeyTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;


@end

@implementation TTPlatformCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavigationWithTitle:@"Custom" rightButtonTitle:nil];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    PlatformModel * model =  [[TTCoreDataClass shareInstance] getPlatformWithName:custom];
    if (model) {
        _streamUrlTextFiled.text = model.rtmp;
        _streamKeyTextFiled.text = model.streamKey;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - 👣 Target actions

- (IBAction)resetButtonClick:(id)sender {
    UIButton * button = (UIButton *)sender;
    if ([button.currentTitle isEqualToString:@"Reset"])
    {
        _streamKeyTextFiled.text = @"";
        _streamUrlTextFiled.text = @"";
        
    }
    else if ([button.currentTitle isEqualToString:@"Save"])
    {
        
        NSString * streamUrl = _streamUrlTextFiled.text;
        NSString * streamKey = _streamKeyTextFiled.text;
        
        if (streamUrl.length == 0 || streamKey.length == 0) {
            [self showHudMessage:NSLocalizedString(@"CustomUrlFillError", nil)];
            return;
        }
        
        if ([streamUrl IsChinese] || [streamKey IsChinese]) {
            [self showHudMessage:NSLocalizedString(@"CustomUrlFillError", nil)];
            return;
        }
        
        if (![streamUrl hasPrefix:@"rtmp:"] && ![streamUrl hasPrefix:@"RTMP:"]) {
            [self showHudMessage:NSLocalizedString(@"CustomUrlFillError", nil)];
            return;
        }
        
        BOOL save = [[TTCoreDataClass shareInstance] updatePlatformWithName:custom rtmp:streamUrl streamKey:streamKey customString:nil enabel:YES selected:YES];
        if (save)
        {
            [self showHudMessage:NSLocalizedString(@"SaveSuccess", nil)];
        }
        else
        {
            [self showHudMessage:NSLocalizedString(@"SaveFail", nil)];
        }
        
        
    }

}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (!_streamKeyTextFiled.isFirstResponder) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    keyboardHeight = keyboardRect.size.height;
    
    CGFloat offsetY = 0;
    CGFloat maxY = CGRectGetMaxY(_streamKeyTextFiled.frame);
    offsetY = keyboardHeight - (ScreenHeight - maxY);
    if (offsetY>0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.frame = CGRectMake(0, -offsetY, ScreenWidth, ScreenHeight+offsetY);
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    keyboardHeight = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    } completion:^(BOOL finished) {
        
    }];
    
}


#pragma mark - 🤝 Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_resetButton setTitle:@"Save" forState:UIControlStateNormal];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
