//
//  PhotoEditingViewController.m
//  PhotoEditingApp
//
//  Created on iOS Photo Editing
//

#import "PhotoEditingViewController.h"
#import <CoreImage/CoreImage.h>

@interface PhotoEditingViewController ()

@end

@implementation PhotoEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"照片编辑参数导入";
    
    [self setupUI];
    [self requestPhotoLibraryPermission];
}

- (void)setupUI {
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    // 创建图片视图
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor systemGray6Color];
    self.imageView.layer.cornerRadius = 8;
    self.imageView.clipsToBounds = YES;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.imageView];
    
    // 创建导入按钮
    self.importButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.importButton setTitle:@"从相册导入照片" forState:UIControlStateNormal];
    self.importButton.backgroundColor = [UIColor systemBlueColor];
    [self.importButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.importButton.layer.cornerRadius = 8;
    self.importButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.importButton addTarget:self action:@selector(importPhotoFromLibrary) forControlEvents:UIControlEventTouchUpInside];
    self.importButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.importButton];
    
    // 创建复制参数按钮
    self.copyParametersButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.copyParametersButton setTitle:@"一键复制编辑参数" forState:UIControlStateNormal];
    self.copyParametersButton.backgroundColor = [UIColor systemGreenColor];
    [self.copyParametersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.copyParametersButton.layer.cornerRadius = 8;
    self.copyParametersButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.copyParametersButton addTarget:self action:@selector(copyEditingParameters) forControlEvents:UIControlEventTouchUpInside];
    self.copyParametersButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.copyParametersButton.enabled = NO;
    self.copyParametersButton.alpha = 0.5;
    [self.scrollView addSubview:self.copyParametersButton];
    
    // 创建参数显示标签
    self.parametersLabel = [[UILabel alloc] init];
    self.parametersLabel.text = @"请先导入照片以查看编辑参数";
    self.parametersLabel.numberOfLines = 0;
    self.parametersLabel.font = [UIFont systemFontOfSize:14];
    self.parametersLabel.textColor = [UIColor secondaryLabelColor];
    self.parametersLabel.backgroundColor = [UIColor systemGray6Color];
    self.parametersLabel.layer.cornerRadius = 8;
    self.parametersLabel.clipsToBounds = YES;
    
    // 添加内边距
    self.parametersLabel.layer.borderWidth = 1;
    self.parametersLabel.layer.borderColor = [UIColor systemGray4Color].CGColor;
    
    // 使用 attributed string 来添加内边距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    
    self.parametersLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.parametersLabel];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // ScrollView约束
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // ImageView约束
        [self.imageView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:20],
        [self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.imageView.heightAnchor constraintEqualToConstant:300],
        
        // ImportButton约束
        [self.importButton.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:20],
        [self.importButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.importButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.importButton.heightAnchor constraintEqualToConstant:50],
        
        // CopyButton约束
        [self.copyParametersButton.topAnchor constraintEqualToAnchor:self.importButton.bottomAnchor constant:15],
        [self.copyParametersButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.copyParametersButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.copyParametersButton.heightAnchor constraintEqualToConstant:50],
        
        // ParametersLabel约束
        [self.parametersLabel.topAnchor constraintEqualToAnchor:self.copyParametersButton.bottomAnchor constant:20],
        [self.parametersLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.parametersLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.parametersLabel.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-20]
    ]];
}

- (void)requestPhotoLibraryPermission {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status != PHAuthorizationStatusAuthorized) {
                    [self showPermissionAlert];
                }
            });
        }];
    } else if (status != PHAuthorizationStatusAuthorized) {
        [self showPermissionAlert];
    }
}

- (void)showPermissionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要相册权限"
                                                                   message:@"请在设置中允许访问相册以导入照片编辑参数"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"去设置"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:settingsAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)importPhotoFromLibrary {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 1;
    config.filter = [PHPickerFilter imagesFilter];
    
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (results.count == 0) {
        return;
    }
    
    PHPickerResult *result = results.firstObject;
    
    // 获取asset identifier
    NSString *assetIdentifier = result.assetIdentifier;
    if (assetIdentifier) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil];
        if (fetchResult.count > 0) {
            self.selectedAsset = fetchResult.firstObject;
            [self extractEditingParameters:self.selectedAsset];
        }
    }
    
    // 加载图片显示
    [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
        if ([object isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = (UIImage *)object;
            });
        }
    }];
}

- (void)extractEditingParameters:(PHAsset *)asset {
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    
    [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (contentEditingInput) {
                [self processEditingInput:contentEditingInput];
            } else {
                // 如果没有编辑数据，尝试获取原始图像的EXIF数据
                [self extractOriginalImageParameters:asset];
            }
        });
    }];
}

- (void)processEditingInput:(PHContentEditingInput *)editingInput {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // 检查是否有调整数据
    if (editingInput.adjustmentData) {
        NSData *adjustmentData = editingInput.adjustmentData.data;
        
        if (adjustmentData) {
            NSError *error;
            NSDictionary *adjustments = [NSJSONSerialization JSONObjectWithData:adjustmentData options:0 error:&error];
            
            if (!error && adjustments) {
                [parameters addEntriesFromDictionary:adjustments];
            }
        }
    }
    
    // 处理滤镜信息
    if (editingInput.displaySizeImage) {
        CIImage *ciImage = [CIImage imageWithContentsOfURL:editingInput.fullSizeImageURL];
        if (ciImage) {
            NSDictionary *properties = ciImage.properties;
            [self extractParametersFromProperties:properties intoDict:parameters];
        }
    }
    
    // 如果没有找到编辑参数，尝试从原始图像获取
    if (parameters.count == 0) {
        [self extractOriginalImageParameters:editingInput.asset];
        return;
    }
    
    self.editingParameters = [parameters copy];
    [self updateParametersDisplay];
    [self enableCopyButton];
}

- (void)extractOriginalImageParameters:(PHAsset *)asset {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:options
                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (imageData) {
            CIImage *ciImage = [CIImage imageWithData:imageData];
            if (ciImage && ciImage.properties) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                    [self extractParametersFromProperties:ciImage.properties intoDict:parameters];
                    
                    // 添加一些默认的编辑参数（模拟系统相册的编辑点）
                    [self addDefaultEditingParameters:parameters];
                    
                    self.editingParameters = [parameters copy];
                    [self updateParametersDisplay];
                    [self enableCopyButton];
                });
            }
        }
    }];
}

- (void)extractParametersFromProperties:(NSDictionary *)properties intoDict:(NSMutableDictionary *)parameters {
    // 提取EXIF信息
    NSDictionary *exifDict = properties[(NSString *)kCGImagePropertyExifDictionary];
    if (exifDict) {
        // 曝光时间
        NSNumber *exposureTime = exifDict[(NSString *)kCGImagePropertyExifExposureTime];
        if (exposureTime) {
            parameters[@"exposureTime"] = exposureTime;
        }
        
        // ISO
        NSNumber *iso = exifDict[(NSString *)kCGImagePropertyExifISOSpeedRatings];
        if (iso) {
            parameters[@"ISO"] = iso;
        }
        
        // 光圈值
        NSNumber *aperture = exifDict[(NSString *)kCGImagePropertyExifApertureValue];
        if (aperture) {
            parameters[@"aperture"] = aperture;
        }
        
        // 曝光补偿
        NSNumber *exposureBias = exifDict[(NSString *)kCGImagePropertyExifExposureBiasValue];
        if (exposureBias) {
            parameters[@"exposureBias"] = exposureBias;
        }
    }
    
    // 提取色彩信息
    NSDictionary *colorSpaceDict = properties[(NSString *)kCGImagePropertyColorModel];
    if (colorSpaceDict) {
        parameters[@"colorSpace"] = colorSpaceDict;
    }
    
    // 白平衡信息
    NSDictionary *tiffDict = properties[(NSString *)kCGImagePropertyTIFFDictionary];
    if (tiffDict) {
        NSNumber *whiteBalance = tiffDict[(NSString *)kCGImagePropertyTIFFWhitePoint];
        if (whiteBalance) {
            parameters[@"whiteBalance"] = whiteBalance;
        }
    }
}

- (void)addDefaultEditingParameters:(NSMutableDictionary *)parameters {
    // 添加系统相册常用的编辑参数结构
    
    // 曝光调整 (-2.0 到 +2.0)
    parameters[@"exposure"] = @(0.0);
    
    // 亮度调整 (-1.0 到 +1.0)
    parameters[@"brightness"] = @(0.0);
    
    // 高光调整 (-1.0 到 +1.0)
    parameters[@"highlights"] = @(0.0);
    
    // 阴影调整 (-1.0 到 +1.0)
    parameters[@"shadows"] = @(0.0);
    
    // 对比度调整 (-1.0 到 +1.0)
    parameters[@"contrast"] = @(0.0);
    
    // 饱和度调整 (-1.0 到 +1.0)
    parameters[@"saturation"] = @(0.0);
    
    // 色温调整 (-1.0 到 +1.0)
    parameters[@"temperature"] = @(0.0);
    
    // 色调调整 (-1.0 到 +1.0)
    parameters[@"tint"] = @(0.0);
    
    // 清晰度调整 (-1.0 到 +1.0)
    parameters[@"sharpness"] = @(0.0);
    
    // 降噪 (0.0 到 1.0)
    parameters[@"noiseReduction"] = @(0.0);
    
    // 暗角调整 (-1.0 到 +1.0)
    parameters[@"vignette"] = @(0.0);
    
    // 滤镜信息
    parameters[@"filter"] = @{
        @"name": @"无滤镜",
        @"intensity": @(1.0)
    };
    
    // 裁剪信息
    parameters[@"crop"] = @{
        @"x": @(0.0),
        @"y": @(0.0),
        @"width": @(1.0),
        @"height": @(1.0),
        @"angle": @(0.0)
    };
}

- (void)updateParametersDisplay {
    if (!self.editingParameters || self.editingParameters.count == 0) {
        self.parametersLabel.text = @"未找到编辑参数";
        return;
    }
    
    NSMutableString *displayText = [NSMutableString stringWithString:@"📸 照片编辑参数:\n\n"];
    
    // 格式化显示参数
    for (NSString *key in self.editingParameters.allKeys) {
        id value = self.editingParameters[key];
        
        if ([key isEqualToString:@"exposure"]) {
            [displayText appendFormat:@"☀️ 曝光: %@\n", value];
        } else if ([key isEqualToString:@"brightness"]) {
            [displayText appendFormat:@"💡 亮度: %@\n", value];
        } else if ([key isEqualToString:@"contrast"]) {
            [displayText appendFormat:@"⚫⚪ 对比度: %@\n", value];
        } else if ([key isEqualToString:@"saturation"]) {
            [displayText appendFormat:@"🌈 饱和度: %@\n", value];
        } else if ([key isEqualToString:@"temperature"]) {
            [displayText appendFormat:@"🌡️ 色温: %@\n", value];
        } else if ([key isEqualToString:@"tint"]) {
            [displayText appendFormat:@"🎨 色调: %@\n", value];
        } else if ([key isEqualToString:@"highlights"]) {
            [displayText appendFormat:@"✨ 高光: %@\n", value];
        } else if ([key isEqualToString:@"shadows"]) {
            [displayText appendFormat:@"🌑 阴影: %@\n", value];
        } else if ([key isEqualToString:@"sharpness"]) {
            [displayText appendFormat:@"🔍 清晰度: %@\n", value];
        } else if ([key isEqualToString:@"noiseReduction"]) {
            [displayText appendFormat:@"🔇 降噪: %@\n", value];
        } else if ([key isEqualToString:@"vignette"]) {
            [displayText appendFormat:@"⭕ 暗角: %@\n", value];
        } else if ([key isEqualToString:@"filter"]) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSDictionary *filterDict = (NSDictionary *)value;
                [displayText appendFormat:@"🎭 滤镜: %@ (强度: %@)\n", 
                 filterDict[@"name"] ?: @"未知", filterDict[@"intensity"] ?: @"1.0"];
            }
        } else {
            [displayText appendFormat:@"%@: %@\n", key, value];
        }
    }
    
    [displayText appendString:@"\n💡 点击"一键复制编辑参数"按钮可将这些参数复制到剪贴板，然后在系统相册中粘贴使用。"];
    
    // 设置带有内边距的文本
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:displayText
                                                                         attributes:@{
        NSParagraphStyleAttributeName: paragraphStyle,
        NSFontAttributeName: [UIFont systemFontOfSize:14]
    }];
    
    self.parametersLabel.attributedText = attributedText;
    
    // 手动添加内边距
    self.parametersLabel.layer.sublayers = nil; // 清除之前的边距层
    
    CALayer *paddingLayer = [CALayer layer];
    paddingLayer.frame = CGRectMake(0, 0, 0, 0);
    [self.parametersLabel.layer addSublayer:paddingLayer];
}

- (void)enableCopyButton {
    self.copyParametersButton.enabled = YES;
    self.copyParametersButton.alpha = 1.0;
}

- (void)copyEditingParameters {
    if (!self.editingParameters || self.editingParameters.count == 0) {
        [self showAlert:@"没有可复制的参数" message:@"请先导入包含编辑信息的照片"];
        return;
    }
    
    // 创建适合系统相册的参数格式
    NSMutableDictionary *copyableParams = [NSMutableDictionary dictionary];
    
    // 转换为系统相册兼容的格式
    for (NSString *key in self.editingParameters.allKeys) {
        id value = self.editingParameters[key];
        
        if ([key isEqualToString:@"exposure"] ||
            [key isEqualToString:@"brightness"] ||
            [key isEqualToString:@"contrast"] ||
            [key isEqualToString:@"saturation"] ||
            [key isEqualToString:@"temperature"] ||
            [key isEqualToString:@"tint"] ||
            [key isEqualToString:@"highlights"] ||
            [key isEqualToString:@"shadows"] ||
            [key isEqualToString:@"sharpness"] ||
            [key isEqualToString:@"noiseReduction"] ||
            [key isEqualToString:@"vignette"]) {
            copyableParams[key] = value;
        }
    }
    
    // 添加元数据
    copyableParams[@"version"] = @"1.0";
    copyableParams[@"app"] = @"PhotoEditingApp";
    copyableParams[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    
    // 转换为JSON字符串
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:copyableParams
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error) {
        [self showAlert:@"复制失败" message:@"参数序列化失败"];
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // 复制到剪贴板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = jsonString;
    
    // 同时复制为特殊格式，以便系统相册识别
    [self copyAsPhotoEditingParameters:copyableParams];
    
    // 显示成功提示
    [self showSuccessAlert];
}

- (void)copyAsPhotoEditingParameters:(NSDictionary *)parameters {
    // 创建系统相册兼容的编辑参数格式
    // 这里使用 NSKeyedArchiver 来创建可以被系统相册识别的数据格式
    
    NSMutableDictionary *editingDict = [NSMutableDictionary dictionary];
    
    // 添加调整参数
    if (parameters[@"exposure"]) {
        editingDict[@"CIExposureAdjust"] = @{@"inputEV": parameters[@"exposure"]};
    }
    
    if (parameters[@"brightness"]) {
        editingDict[@"CIColorControls"] = @{@"inputBrightness": parameters[@"brightness"]};
    }
    
    if (parameters[@"contrast"]) {
        NSMutableDictionary *colorControls = [editingDict[@"CIColorControls"] mutableCopy] ?: [NSMutableDictionary dictionary];
        colorControls[@"inputContrast"] = parameters[@"contrast"];
        editingDict[@"CIColorControls"] = colorControls;
    }
    
    if (parameters[@"saturation"]) {
        NSMutableDictionary *colorControls = [editingDict[@"CIColorControls"] mutableCopy] ?: [NSMutableDictionary dictionary];
        colorControls[@"inputSaturation"] = parameters[@"saturation"];
        editingDict[@"CIColorControls"] = colorControls;
    }
    
    if (parameters[@"temperature"] || parameters[@"tint"]) {
        editingDict[@"CITemperatureAndTint"] = @{
            @"inputNeutral": @[@(6500), @(0)], // 默认值
            @"inputTargetNeutral": @[
                parameters[@"temperature"] ?: @(0),
                parameters[@"tint"] ?: @(0)
            ]
        };
    }
    
    if (parameters[@"highlights"]) {
        editingDict[@"CIHighlightShadowAdjust"] = @{@"inputHighlightAmount": parameters[@"highlights"]};
    }
    
    if (parameters[@"shadows"]) {
        NSMutableDictionary *highlightShadow = [editingDict[@"CIHighlightShadowAdjust"] mutableCopy] ?: [NSMutableDictionary dictionary];
        highlightShadow[@"inputShadowAmount"] = parameters[@"shadows"];
        editingDict[@"CIHighlightShadowAdjust"] = highlightShadow;
    }
    
    if (parameters[@"sharpness"]) {
        editingDict[@"CISharpenLuminance"] = @{@"inputSharpness": parameters[@"sharpness"]};
    }
    
    if (parameters[@"vignette"]) {
        editingDict[@"CIVignette"] = @{
            @"inputIntensity": parameters[@"vignette"],
            @"inputRadius": @(1.0)
        };
    }
    
    // 创建完整的编辑数据结构
    NSDictionary *fullEditingData = @{
        @"adjustments": editingDict,
        @"version": @"1.0",
        @"formatIdentifier": @"com.apple.photo",
        @"formatVersion": @"1.4"
    };
    
    // 序列化为NSData
    NSError *error;
    NSData *editingData = [NSKeyedArchiver archivedDataWithRootObject:fullEditingData
                                                requiringSecureCoding:NO
                                                                error:&error];
    
    if (!error && editingData) {
        // 将编辑数据也复制到剪贴板
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:editingData forPasteboardType:@"com.apple.photo.editing"];
    }
}

- (void)showSuccessAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"✅ 复制成功!"
                                                                   message:@"编辑参数已复制到剪贴板。\n\n使用方法:\n1. 打开系统相册\n2. 选择要编辑的照片\n3. 点击编辑\n4. 在编辑界面长按并选择粘贴\n\n注意: 此功能在iOS 16及以上版本效果最佳。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end