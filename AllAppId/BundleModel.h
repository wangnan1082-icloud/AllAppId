//
//  BundleModel.h
//  AllAppId
//
//  Created by 王楠 on 2017/3/16.
//  Copyright © 2017年 combanc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BundleModel : NSObject

@property (nonatomic, copy) NSString *bundlId; /**< bundlId*/
@property (nonatomic, copy) NSString *localizedName; /**< localizedName*/
@property (nonatomic, copy) NSString *localizedShortName; /**< localizedShortName*/

@end
