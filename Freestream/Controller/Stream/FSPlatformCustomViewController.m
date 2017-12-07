//
//  FSPlatformCustomViewController.m
//  Freestream
//
//  Created by Frank Li on 2017/12/5.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "FSPlatformCustomViewController.h"
#import "CommonAppHeader.h"

@interface FSPlatformCustomViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField    *streamAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField    *streamKeyTextField;
@property (weak, nonatomic) IBOutlet UIButton       *saveButton;
@property (weak, nonatomic) IBOutlet UIView         *contentView;

@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,assign) CGFloat                keyboardHeight;

@property (nonatomic,assign) CGFloat                buttonBottomToSuperView;

@property (nonatomic,strong) FSStreamPlatformModel  *model;
@property (nonatomic,strong) NSMutableArray <FSStreamPlatformModel *>*modelsArray;

@end

@implementation FSPlatformCustomViewController

#pragma mark - Setters/Getters
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboardActions)];
        _tapGesture.enabled = NO;
        [self.contentView addGestureRecognizer:_tapGesture];
    }
    return _tapGesture;
}

- (CGFloat)buttonBottomToSuperView {
    if (_buttonBottomToSuperView == 0 ){
        _buttonBottomToSuperView = SCREENHEIGHT - CGRectGetMidY(self.saveButton.frame);
    }
    return _buttonBottomToSuperView;
}

- (NSMutableArray<FSStreamPlatformModel *> *)modelsArray {
    if (!_modelsArray) {
        _modelsArray = @[].mutableCopy;
    }
    return _modelsArray;
}

#pragma mark – View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Custom", nil);
    [self requestDataSource];
    [self addNotifacation];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark – Initialization & Memory management methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – Request service methods

- (void)requestDataSource {
    self.modelsArray = [CoreStore sharedStore].streamPlatformModels.mutableCopy;
    for (FSStreamPlatformModel * model in self.modelsArray) {
        if (model.streamPlatform == FSStreamPlatformCustom) {
            self.model = model;
        }
    }
    if (!self.model) {
        self.model = [[FSStreamPlatformModel alloc] initWithStreamPlatform:FSStreamPlatformCustom];
    } else {
        self.streamKeyTextField.text = self.model.streamKey;
        self.streamAddressTextField.text = self.model.streamAdress;
        [self.saveButton setTitle:@"Reset" forState:UIControlStateNormal];
    }
}

#pragma mark – Private methods

- (void)addNotifacation {
    
    //监听键盘弹出或收回通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (void)keyBoardChange:(NSNotification *)note
{
    //获取键盘弹出或收回时frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //获取键盘弹出所需时长
    float duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //添加弹出动画
    if (keyboardFrame.origin.y == SCREENHEIGHT) {
        [UIView animateWithDuration:duration animations:^{//收起
            self.contentView.transform = CGAffineTransformIdentity;
            self.tapGesture.enabled = NO;
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{//弹出
            self.contentView.transform = CGAffineTransformMakeTranslation(0, -ABS(keyboardFrame.origin.y - self.buttonBottomToSuperView));
            self.tapGesture.enabled = YES;
        }];
    }
}

- (void)dismissKeyboardActions {

    [self tryDismissKeyborad:self.streamAddressTextField];
    [self tryDismissKeyborad:self.streamKeyTextField];    
}

- (void)tryDismissKeyborad:(UITextField *)textField {
    
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
        [textField endEditing:YES];
    }
}

#pragma mark – Target action methods

- (IBAction)buttonClickAction:(UIButton *)sender {
    [self dismissKeyboardActions];
    if ([sender.currentTitle isEqualToString:@"Reset"]) {
        self.streamAddressTextField.text = @"";
        self.streamKeyTextField.text = @"";
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    } else if ([sender.currentTitle isEqualToString:@"Save"]) {
        
        NSString * streamUrl = self.streamAddressTextField.text;
        NSString * streamKey = self.streamKeyTextField.text;
        
        if (streamUrl.length == 0 || streamKey.length == 0) {
            [self showHudMessage:NSLocalizedString(@"CustomUrlFillError", nil)];
            return;
        }
        
        if ([streamUrl hasContainsChineseCharacter] || [streamKey hasContainsChineseCharacter]) {
            [self showHudMessage:NSLocalizedString(@"CustomUrlFillError", nil)];
            return;
        }
        
        if (![streamUrl hasPrefix:@"rtmp:"] && ![streamUrl hasPrefix:@"RTMP:"]) {
            [self showHudMessage:NSLocalizedString(@"CustomUrlFillError", nil)];
            return;
        }
        
        self.model.streamAdress = streamUrl;
        self.model.streamKey = streamKey;
        self.model.buttonStatus = FSStreamPlatformButtonStatusSelected;
        NSInteger idx = -1;
        for (FSStreamPlatformModel * model in self.modelsArray) {
            if (model.streamPlatform == FSStreamPlatformCustom) {
               idx = [self.modelsArray indexOfObject:model];
            }
        }
        
        if (idx > -1) {
            [self.modelsArray replaceObjectAtIndex:idx withObject:self.model];
        } else {
            [self.modelsArray addObject:self.model];
        }
        
        [CoreStore sharedStore].streamPlatformModels = self.modelsArray;
        
        [self showHudMessage:NSLocalizedString(@"SaveSuccess", nil)];
    }
}

#pragma mark - IBActions

#pragma mark – Public methods

#pragma mark – Class methods

#pragma mark – Override properties

#pragma mark - Override super methods

#pragma mark – Delegate
#pragma mark – UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.streamAddressTextField){
        [self.streamKeyTextField becomeFirstResponder];}
    else if(textField == self.streamKeyTextField){
        [textField resignFirstResponder];
        [self performSelector:@selector(buttonClickAction:) withObject:self.saveButton];
    }
    return YES;
}


@end
