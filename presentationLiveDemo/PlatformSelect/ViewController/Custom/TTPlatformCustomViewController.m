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
@property (weak, nonatomic) IBOutlet UITextField *streamUrlTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *streamKeyTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

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
    
    PlatformModel * model =  [[TTCoreDataClass shareInstance] getPlatformWithName:custom];
    if (model) {
        _streamUrlTextFiled.text = model.rtmp;
        _streamKeyTextFiled.text = model.streamKey;
    }
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
        
        NSString * lastChar = [streamUrl substringFromIndex:streamUrl.length-1];
        if (![lastChar isEqualToString:@"/"]) {
            streamUrl = [NSString stringWithFormat:@"%@/",streamUrl];
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
