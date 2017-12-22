//
//  ViewController.m
//  pngCompositionGif
//
//  Created by jason on 2017/12/18.
//  Copyright © 2017年 nemo. All rights reserved.
//

#import "ViewController.h"
//#define NAME_IMAGE @"千と千尋"
#define NAME_IMAGE @"hb"
#import <ImageIO/ImageIO.h>
#import <CoreImage/CoreImage.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *textViewGifToPng;

@property(nonatomic,strong) NSMutableArray * mutArrImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self basicConfiguration];
}
- (void)basicConfiguration{
    NSString * path = [[NSBundle mainBundle] pathForResource:NAME_IMAGE ofType:@"gif"];
    NSData * data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedAlways error:nil];
    [_webView loadData:data MIMEType:@"image/gif" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:path]];
}

- (IBAction)btnActionGitToPng:(id)sender {
    /**
     0 获取gif data
     1 转化
     */
    NSString * path = [[NSBundle mainBundle] pathForResource:NAME_IMAGE ofType:@"gif"];
    NSData * data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    
    CGImageSourceRef  imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    NSMutableArray * mutArr = [NSMutableArray array];
    self.mutArrImage = mutArr;
    size_t count = CGImageSourceGetCount(imageSource);
    for (int i = 0;  i<count; i++) {
        CGImageRef imageRef =CGImageSourceCreateImageAtIndex(imageSource, i, nil);
        UIImage * image = [UIImage imageWithCGImage:imageRef];
         [mutArr addObject:image];
        CGImageRelease(imageRef);
    }
    
    NSString * pathDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _textViewGifToPng.text = pathDocument;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * dirStr = [pathDocument stringByAppendingString:@"/png"];
    [fileManager  createDirectoryAtPath:dirStr withIntermediateDirectories:YES attributes:nil error:nil];
    
    for (int i = 0; i<mutArr.count; i++) {
        NSString * newFile = [NSString stringWithFormat:@"%@/%@%d.png",dirStr,NAME_IMAGE,i];
        UIImage * image = mutArr[i];
        [fileManager createFileAtPath:newFile contents:UIImagePNGRepresentation(image) attributes:nil];
    }
    
}

- (IBAction)btnActionPngToGif:(id)sender {
    /**
        0 获得 png 路径 保存地址路径
        1 转化
     */
    NSString * pathDoc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString * pathDir = [pathDoc stringByAppendingPathComponent:@"png"];
  
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager isExecutableFileAtPath:pathDir]) {
        
    }else{
        [fileManager createDirectoryAtPath:pathDir withIntermediateDirectories:kCGImagePropertyExifFocalPlaneYResolution attributes:nil error:nil];
    }
 
    
    NSMutableArray * mutImages = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i<10; i++) {//temp 10
        NSString * filePath = [pathDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png",NAME_IMAGE,i]];
        UIImage * image = [UIImage imageWithContentsOfFile:filePath];
        [mutImages addObject:image];
    }
    
    NSString * gifStr = [NSString stringWithFormat:@"%@test.gif",NAME_IMAGE];
    NSString * pathGif = [pathDir stringByAppendingPathComponent:gifStr];
    
 
    //配置 gif
     CFURLRef urlRef =CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)pathGif, kCFURLPOSIXPathStyle, false);
    
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL(urlRef, kUTTypeGIF, mutImages.count, nil);
    
//    NSDictionary * dict = @{[NSNumber numberWithLong:kCGImagePropertyGIFDelayTime]:@"0.1"};
    NSObject * obj  = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:5],(NSString*)kCGImagePropertyGIFDelayTime, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:obj forKey:(NSString*)kCGImagePropertyGIFDelayTime];
 
    CFDictionaryRef dictRef = (__bridge CFDictionaryRef)(dict);
    for (UIImage * image  in mutImages) {
        CGImageDestinationAddImage(destinationRef,image.CGImage, dictRef);
    }
    NSMutableDictionary * mutDic = [[NSMutableDictionary alloc] init];
//    mutDic set
    
    [mutDic setValue:[NSNumber numberWithInteger:kCGImagePropertyColorModelRGB] forKey:@"kCGImagePropertyColorModelRGB"];
    [mutDic setValue:@(16) forKey:@"kCGImagePropertyDepth"];
    [mutDic setValue:@(3) forKey:@"kCGImagePropertyGIFLoopCount"];
    [mutDic setValue:@(YES) forKey:@"kCGImagePropertyGIFHasGlobalColorMap"];
    
//    //生成GIF图片成功
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCGImagePropertyGIFLoopCount]forKey:(NSString *)kCGImagePropertyGIFDictionary];
    CGImageDestinationSetProperties(destinationRef, (CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destinationRef);
    CFRelease(destinationRef);
    
    
} 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC{
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    segue.destinationViewController;
    segue.identifier;
    
}
@end
