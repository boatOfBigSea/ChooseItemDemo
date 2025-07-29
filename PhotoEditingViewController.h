//
//  PhotoEditingViewController.h
//  PhotoEditingApp
//
//  Created on iOS Photo Editing
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@interface PhotoEditingViewController : UIViewController <PHPickerViewControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *importButton;
@property (nonatomic, strong) UIButton *copyParametersButton;
@property (nonatomic, strong) UILabel *parametersLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) PHAsset *selectedAsset;
@property (nonatomic, strong) NSDictionary *editingParameters;

- (void)importPhotoFromLibrary;
- (void)copyEditingParameters;
- (void)extractEditingParameters:(PHAsset *)asset;
- (void)findAssetFromPickerResult:(PHPickerResult *)result;
- (void)findAssetByImageProperties:(NSDictionary *)properties imageData:(NSData *)imageData;
- (void)matchAssetByComparison:(PHFetchResult<PHAsset *> *)assets imageData:(NSData *)imageData properties:(NSDictionary *)properties;
- (void)extractParametersFromImageData:(NSData *)imageData;
- (void)handleAuthorizationStatus:(PHAuthorizationStatus)status;
- (void)showLimitedAccessAlert;
- (void)presentPhotoPickerWithPermissionStatus:(PHAuthorizationStatus)status;

@end