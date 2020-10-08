//
//  SDWebImageAPNGCoder.h
//  SDWebImageAPNGCoder
//
//  Created by DreamPiggy on 2017/11/2.
//

#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
@import SDWebImage;
#endif

@interface SDImageAPNGCoder2 : NSObject <SDImageCoder>

@property (nonatomic, class, readonly, nonnull) SDImageAPNGCoder2 *sharedCoder;

@end
