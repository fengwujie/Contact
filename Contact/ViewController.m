//
//  ViewController.m
//  Contact
//
//  Created by allen on 16/5/15.
//  Copyright © 2016年 allen. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;

- (IBAction)btnAddContact:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //1.获取授权状态
    ABAuthorizationStatus type =  ABAddressBookGetAuthorizationStatus();
    //授权申请
    if (type == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"授权允许");
            }else{
                NSLog(@"授权拒绝");
            }
        });
        //释放book
        CFRelease(book);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAddContact:(id)sender {
    NSError *error;
    NSString *textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"contact" ofType:@"txt"] encoding:NSUTF8StringEncoding error: &error];
    NSURL *url = [NSURL URLWithString:@"file:///Users/allen/Desktop/contact.txt" ];
    
//    NSString *textFileContents = [NSString stringWithContentsOfFile:@"file:///Users/allen/Desktop/contact.txt" encoding:NSUTF8StringEncoding error: &error];
//    NSURL *url = [NSURL URLWithString:@"file:///Users/allen/Desktop/contact.txt" ];
//    NSString *textFileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if(textFileContents == nil)
    {
        NSLog(@"Error:No Find File");
    }
    else
    {
        NSArray *lines = [textFileContents componentsSeparatedByString:@"\n"];
        NSLog(@"Number of lines in the file:%ld",[lines count]);
        NSLog(@"lines is %@",lines);
        
//        for (NSString *line in lines) {
//            [self addContact:line];
//        }
    }
}



//add contact
-(void)addContact:(NSString* )line{
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
//    NSLog(@"%@",self.txtName.text);
//    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(self.txtName.text), &error);
//    NSLog(@"%@",self.txtPhone.text);
    
    //创建一个多值属性(电话)
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)line, kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multi, &error);
    
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(newPerson);
    CFRelease(iPhoneAddressBook);

    NSLog(@"添加成功！");
}
@end
