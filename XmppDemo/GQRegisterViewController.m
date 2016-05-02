//
//  GQRegisterViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/4/27.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQRegisterViewController.h"
#import "GQStreamManager.h"
#import "GQStatic.h"

@interface GQRegisterViewController () <UITextFieldDelegate> {
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField1;
@property (weak, nonatomic) IBOutlet UITextField *passwordField2;
@property (weak, nonatomic) IBOutlet UITextField *serverAddressField;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) GQStreamManager *streamManager;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *serverAddress;


- (IBAction)register:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)textChanged:(id)sender;

@end

@implementation GQRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _streamManager = [GQStreamManager manager];
    _nameField.delegate = self;
    _passwordField1.delegate = self;
    _passwordField2.delegate = self;
    _serverAddressField.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerSuccess) name:STREAM_MANAGER_REGISTER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerFail) name:STREAM_MANAGER_REGISTER_FAIL object:nil];
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

- (IBAction)register:(id)sender {
    if ([self checkInputs]) {
        [self.streamManager registerWithName:self.name Password:self.password ServerAddress:self.serverAddress];
        NSLog(@"register");
    }
    
}

- (BOOL)checkInputs {
    NSString *empty = @"";
    self.name = self.nameField.text;
    if ([self.name isEqualToString:empty]) {
        self.warningLabel.text = @"name can't be empty";
        return NO;
    }
    
    self.password = self.passwordField1.text;
    if ([self.password isEqualToString:empty]) {
        self.warningLabel.text = @"password can't be empty";
        return NO;
    }
    if ([self.passwordField2.text isEqualToString:empty]) {
        self.warningLabel.text = @"confirm password can't be empty";
        return NO;
    }
    if (![self.passwordField2.text isEqualToString:self.password]) {
        self.warningLabel.text = @"twice passwords must be the same";
        return NO;
    }
    
    self.serverAddress = self.serverAddressField.text;
    if ([self.serverAddress isEqualToString:empty]) {
        self.warningLabel.text = @"server address can't be empty";
        return NO;
    }
    return YES;
}

#pragma mark- UITextField delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![self.passwordField1.text isEqualToString:self.passwordField2.text]) {
        self.warningLabel.text = @"twice passwords must be the same";
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.warningLabel.text = @"";
}

#pragma mark hideKeboard Methods
- (IBAction)hideKeyboard:(id)sender {
    [self.nameField resignFirstResponder];
    [self.passwordField1 resignFirstResponder];
    [self.passwordField2 resignFirstResponder];
    [self.serverAddressField resignFirstResponder];
}

- (IBAction)textChanged:(id)sender {
    self.registerButton.enabled = (self.nameField.text.length > 0 &&
                                   self.passwordField1.text.length > 0 &&
                                   self.passwordField2.text.length > 0 &&
                                   self.serverAddressField.text.length > 0);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nameField resignFirstResponder];
    [self.passwordField1 resignFirstResponder];
    [self.passwordField2 resignFirstResponder];
    [self.serverAddressField resignFirstResponder];
}

- (void)registerFail {
    self.warningLabel.text = @"Register failed. Change a name";
}

- (void)registerSuccess {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Register success"
                                                                             message:@"Tap OK to login"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:backAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
