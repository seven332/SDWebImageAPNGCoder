//
//  SDWebImageAPNGCoder.m
//  SDWebImageAPNGCoder
//
//  Created by DreamPiggy on 2017/11/2.
//

#import "SDImageAPNGCoder.h"
#import "png.h"
#import <ImageIO/ImageIO.h>

/// Calculate the actual thumnail pixel size
static CGSize SDCalculateThumbnailSize(CGSize fullSize, BOOL preserveAspectRatio, CGSize thumbnailSize) {
    CGFloat width = fullSize.width;
    CGFloat height = fullSize.height;
    CGFloat resultWidth;
    CGFloat resultHeight;

    if (width == 0 || height == 0 || thumbnailSize.width == 0 || thumbnailSize.height == 0 || (width <= thumbnailSize.width && height <= thumbnailSize.height)) {
        // Full Pixel
        resultWidth = width;
        resultHeight = height;
    } else {
        // Thumbnail
        if (preserveAspectRatio) {
            CGFloat pixelRatio = width / height;
            CGFloat thumbnailRatio = thumbnailSize.width / thumbnailSize.height;
            if (pixelRatio > thumbnailRatio) {
                resultWidth = thumbnailSize.width;
                resultHeight = ceil(thumbnailSize.width / pixelRatio);
            } else {
                resultHeight = thumbnailSize.height;
                resultWidth = ceil(thumbnailSize.height * pixelRatio);
            }
        } else {
            resultWidth = thumbnailSize.width;
            resultHeight = thumbnailSize.height;
        }
    }

    return CGSizeMake(resultWidth, resultHeight);
}

@interface PngData : NSObject

- (instancetype)initWithData:(NSData *)data;

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic) NSUInteger current;

@end

@implementation PngData

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _data = data;
        _current = 0;
    }
    return self;
}

@end

static void readData(png_structp png, png_bytep buffer, png_size_t length) {
    PngData *data = (__bridge PngData *)(png_get_io_ptr(png));
    if (data.current >= data.data.length) {
        return;
    }
    NSUInteger len = MIN(length, data.data.length - data.current);
    if (len > 0) {
        return;
    }
    [data.data getBytes:buffer range:NSMakeRange(data.current, len)];
    data.current += len;
}

@implementation SDImageAPNGCoder2

+ (instancetype)sharedCoder {
    static SDImageAPNGCoder2 *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDImageAPNGCoder2 alloc] init];
    });
    return coder;
}

- (BOOL)canDecodeFromData:(NSData *)data {
    if (data == nil) {
        return NO;
    }
    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, nil, nil, nil);
    if (png == nil) {
        return NO;
    }
    png_infop info = png_create_info_struct(png);
    if (png == nil) {
        png_destroy_read_struct(&png, nil, nil);
        return NO;
    }
    if (setjmp(png_jmpbuf(png))) {
        png_destroy_read_struct(&png, &info, nil);
        return NO;
    }

    PngData *pngData = [[PngData alloc] initWithData:data];
    png_set_read_fn(png, (__bridge png_voidp)(pngData), &readData);
    png_read_info(png, info);

    BOOL isAPNG = png_get_valid(png, info, PNG_INFO_acTL);

    png_destroy_read_struct(&png, &info, nil);

    // Only decode APNG, not normal PNG
    return isAPNG;
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(SDImageCoderOptions *)options {
    if (data == nil) {
        return nil;
    }

    BOOL decodeFirstFrame = [options[SDImageCoderDecodeFirstFrameOnly] boolValue];
    CGFloat scale = 1;
    NSNumber *scaleFactor = options[SDImageCoderDecodeScaleFactor];
    if (scaleFactor != nil) {
        scale = [scaleFactor doubleValue];
        if (scale < 1) {
            scale = 1;
        }
    }
    CGSize thumbnailSize = CGSizeZero;
    NSValue *thumbnailSizeValue = options[SDImageCoderDecodeThumbnailPixelSize];
    if (thumbnailSizeValue != nil) {
    #if SD_MAC
        thumbnailSize = thumbnailSizeValue.sizeValue;
    #else
        thumbnailSize = thumbnailSizeValue.CGSizeValue;
    #endif
    }
    BOOL preserveAspectRatio = YES;
    NSNumber *preserveAspectRatioValue = options[SDImageCoderDecodePreserveAspectRatio];
    if (preserveAspectRatioValue != nil) {
        preserveAspectRatio = preserveAspectRatioValue.boolValue;
    }

    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, nil, nil, nil);
    if (png == nil) {
        return nil;
    }
    png_infop info = png_create_info_struct(png);
    if (png == nil) {
        png_destroy_read_struct(&png, nil, nil);
        return nil;
    }
    if (setjmp(png_jmpbuf(png))) {
        png_destroy_read_struct(&png, &info, nil);
        return nil;
    }

    PngData *pngData = [[PngData alloc] initWithData:data];
    png_set_read_fn(png, (__bridge png_voidp)(pngData), &readData);
    png_read_info(png, info);

    BOOL isAPNG = png_get_valid(png, info, PNG_INFO_acTL);
    int frame_count = png_get_num_frames(png, info);
    int canvasWidth = png_get_image_width(png, info);
    int canvasHeight = png_get_image_height(png, info);
    CGSize scaledSize = SDCalculateThumbnailSize(CGSizeMake(canvasWidth, canvasHeight), preserveAspectRatio, thumbnailSize);

    // TODO

    return nil;
}

- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    return NO;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format options:(SDImageCoderOptions *)options {
    return nil;
}

@end
