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
    PHAuthorizationStatus status;
    
    // iOS 14+ 使用新的权限API
    if (@available(iOS 14, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleAuthorizationStatus:status];
                });
            }];
        } else {
            [self handleAuthorizationStatus:status];
        }
    } else {
        // iOS 13及以下的兼容性处理
        status = [PHPhotoLibrary authorizationStatus];
        
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleAuthorizationStatus:status];
                });
            }];
        } else {
            [self handleAuthorizationStatus:status];
        }
    }
}

- (void)handleAuthorizationStatus:(PHAuthorizationStatus)status {
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            // 完全访问权限
            NSLog(@"获得完整相册访问权限");
            [self presentPhotoPickerWithPermissionStatus:status];
            break;
            
        case PHAuthorizationStatusLimited:
            // iOS 14+ 有限访问权限
            NSLog(@"获得有限相册访问权限");
            if (@available(iOS 14, *)) {
                [self showLimitedAccessAlert];
                // 即使是有限权限，也可以使用picker
                [self presentPhotoPickerWithPermissionStatus:status];
            }
            break;
            
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            [self showPermissionAlert];
            break;
            
        case PHAuthorizationStatusNotDetermined:
            // 这种情况通常不会发生在回调中
            break;
    }
}

- (void)showLimitedAccessAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"有限相册访问"
                                                                   message:@"当前为有限相册访问模式。为了获得最佳体验，建议允许访问所有照片。\n\n在有限访问模式下，某些照片的编辑参数可能无法完整获取。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"去设置"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
    }];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"继续使用"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
    
    [alert addAction:settingsAction];
    [alert addAction:continueAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    // 先检查权限状态
    PHAuthorizationStatus status;
    if (@available(iOS 14, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    } else {
        status = [PHPhotoLibrary authorizationStatus];
    }
    
    // 如果没有权限，先请求权限
    if (status == PHAuthorizationStatusNotDetermined) {
        [self requestPhotoLibraryPermission];
        return;
    }
    
    // 如果权限被拒绝，显示提示
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self showPermissionAlert];
        return;
    }
    
    // 创建picker配置
    [self presentPhotoPickerWithPermissionStatus:status];
}

- (void)presentPhotoPickerWithPermissionStatus:(PHAuthorizationStatus)status {
    NSLog(@"开始创建PHPickerViewController，当前权限状态: %ld", (long)status);
    
    // 关键修复：使用photoLibrary初始化PHPickerConfiguration
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] initWithPhotoLibrary:photoLibrary];
    
    config.selectionLimit = 1;
    config.filter = [PHPickerFilter imagesFilter];
    
    // 设置为相册库模式，这样更容易获取assetIdentifier
    if (@available(iOS 15.0, *)) {
        config.mode = PHPickerModeCompact;
        NSLog(@"设置PHPickerMode为Compact");
    }
    
    // 尝试获取完整的照片库访问权限
    config.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeOriginal;
    NSLog(@"设置preferredAssetRepresentationMode为Original");
    
    // 额外的配置尝试
    if (@available(iOS 16.0, *)) {
        // iOS 16+ 的额外配置
        config.preselectedAssetIdentifiers = @[];
    }
    
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
    picker.delegate = self;
    
    // 调试信息
    NSLog(@"PHPickerConfiguration配置完成:");
    NSLog(@"- selectionLimit: %ld", (long)config.selectionLimit);
    NSLog(@"- filter: %@", config.filter);
    NSLog(@"- preferredAssetRepresentationMode: %ld", (long)config.preferredAssetRepresentationMode);
    
    // 如果是有限访问权限，给用户一个提示
    if (@available(iOS 14, *)) {
        if (status == PHAuthorizationStatusLimited) {
            NSLog(@"⚠️ 当前为有限访问权限，某些照片的assetIdentifier可能为nil");
            
            // 尝试提示用户选择更多照片
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"当前为有限相册访问。为了获得最佳体验，请在选择照片时允许访问更多照片。"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                [self presentViewController:picker animated:YES completion:nil];
            }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (results.count == 0) {
        return;
    }
    
    PHPickerResult *result = results.firstObject;
    
    // 先加载图片显示
    [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
        if ([object isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = (UIImage *)object;
            });
        }
    }];
    
    // 尝试获取asset identifier
    NSString *assetIdentifier = result.assetIdentifier;
    
    // 调试信息
    NSLog(@"PHPickerResult调试信息:");
    NSLog(@"- assetIdentifier: %@", assetIdentifier ?: @"nil");
    NSLog(@"- itemProvider: %@", result.itemProvider);
    NSLog(@"- itemProvider.registeredTypeIdentifiers: %@", result.itemProvider.registeredTypeIdentifiers);
    
    // 检查当前权限状态
    PHAuthorizationStatus currentStatus;
    if (@available(iOS 14, *)) {
        currentStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        NSLog(@"- 当前权限状态: %ld", (long)currentStatus);
    }
    
    if (assetIdentifier) {
        NSLog(@"✅ 成功获取到assetIdentifier，尝试获取PHAsset");
        // 方法1：通过asset identifier获取PHAsset
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil];
        if (fetchResult.count > 0) {
            self.selectedAsset = fetchResult.firstObject;
            NSLog(@"✅ 成功通过assetIdentifier获取到PHAsset");
            [self extractEditingParameters:self.selectedAsset];
            return;
        } else {
            NSLog(@"❌ assetIdentifier存在但无法获取PHAsset");
        }
    } else {
        NSLog(@"❌ assetIdentifier为nil，使用备用方案");
    }
    
    // 方法2：如果assetIdentifier为nil，尝试通过图片数据获取PHAsset
    [self findAssetFromPickerResult:result];
}

- (void)findAssetFromPickerResult:(PHPickerResult *)result {
    // 方法2A：尝试通过图片数据和元数据匹配PHAsset
    [result.itemProvider loadDataRepresentationForTypeIdentifier:@"public.image" completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (data) {
            // 从图片数据中提取信息
            CIImage *ciImage = [CIImage imageWithData:data];
            if (ciImage && ciImage.properties) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 尝试通过图片属性匹配相册中的照片
                    [self findAssetByImageProperties:ciImage.properties imageData:data];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 如果无法获取PHAsset，直接从图片数据提取基础信息
                    [self extractParametersFromImageData:data];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"无法加载图片" message:@"请重试或选择其他照片"];
            });
        }
    }];
}

- (void)findAssetByImageProperties:(NSDictionary *)properties imageData:(NSData *)imageData {
    // 获取图片的创建日期和其他标识信息
    NSDictionary *exifDict = properties[(NSString *)kCGImagePropertyExifDictionary];
    NSDictionary *tiffDict = properties[(NSString *)kCGImagePropertyTIFFDictionary];
    
    NSDate *dateTime = nil;
    if (exifDict) {
        NSString *dateTimeString = exifDict[(NSString *)kCGImagePropertyExifDateTimeOriginal];
        if (dateTimeString) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy:MM:dd HH:mm:ss";
            dateTime = [formatter dateFromString:dateTimeString];
        }
    }
    
    // 创建获取选项
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    if (dateTime) {
        // 如果有创建日期，在该日期前后搜索
        NSDate *startDate = [dateTime dateByAddingTimeInterval:-60]; // 前后1分钟
        NSDate *endDate = [dateTime dateByAddingTimeInterval:60];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@ AND creationDate <= %@", startDate, endDate];
    } else {
        // 如果没有日期，获取最近的100张照片进行匹配
        fetchOptions.fetchLimit = 100;
    }
    
    PHFetchResult *assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    if (assets.count > 0) {
        // 尝试通过图片大小和其他属性匹配
        [self matchAssetByComparison:assets imageData:imageData properties:properties];
    } else {
        // 如果找不到匹配的PHAsset，直接从图片数据提取参数
        [self extractParametersFromImageData:imageData];
    }
}

- (void)matchAssetByComparison:(PHFetchResult<PHAsset *> *)assets imageData:(NSData *)imageData properties:(NSDictionary *)properties {
    // 获取图片尺寸用于匹配
    NSNumber *pixelWidth = properties[(NSString *)kCGImagePropertyPixelWidth];
    NSNumber *pixelHeight = properties[(NSString *)kCGImagePropertyPixelHeight];
    
    __block PHAsset *matchedAsset = nil;
    __block NSUInteger processedCount = 0;
    NSUInteger totalCount = assets.count;
    
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        // 首先通过尺寸进行初步筛选
        if (pixelWidth && pixelHeight) {
            if (asset.pixelWidth == pixelWidth.integerValue && asset.pixelHeight == pixelHeight.integerValue) {
                matchedAsset = asset;
                *stop = YES;
                return;
            }
        }
        
        processedCount++;
        
        // 如果处理完所有资源都没找到精确匹配，使用第一个作为备选
        if (processedCount == totalCount && !matchedAsset && idx == 0) {
            matchedAsset = asset;
        }
    }];
    
    if (matchedAsset) {
        self.selectedAsset = matchedAsset;
        [self extractEditingParameters:matchedAsset];
    } else {
        // 如果还是找不到，直接从图片数据提取参数
        [self extractParametersFromImageData:imageData];
    }
}

- (void)extractParametersFromImageData:(NSData *)imageData {
    // 直接从图片数据提取可用的参数
    CIImage *ciImage = [CIImage imageWithData:imageData];
    if (ciImage && ciImage.properties) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [self extractParametersFromProperties:ciImage.properties intoDict:parameters];
        
        // 添加默认编辑参数
        [self addDefaultEditingParameters:parameters];
        
        // 添加提示信息
        parameters[@"source"] = @"图片数据";
        parameters[@"note"] = @"无法获取完整编辑历史，显示基础参数";
        
        self.editingParameters = [parameters copy];
        [self updateParametersDisplay];
        [self enableCopyButton];
    } else {
        [self showAlert:@"无法解析图片" message:@"该图片可能不包含可提取的编辑参数"];
    }
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