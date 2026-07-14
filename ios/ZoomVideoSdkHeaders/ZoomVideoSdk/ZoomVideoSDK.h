#import <TargetConditionals.h>

#if TARGET_OS_SIMULATOR
#import "../../Pods/ZoomVideoSDK/zoom-video-sdk-iOS/ZoomVideoSDK.xcframework/ios-arm64-simulator/ZoomVideoSDK.framework/Headers/ZoomVideoSDK.h"
#else
#import "../../Pods/ZoomVideoSDK/zoom-video-sdk-iOS/ZoomVideoSDK.xcframework/ios-arm64/ZoomVideoSDK.framework/Headers/ZoomVideoSDK.h"
#endif
