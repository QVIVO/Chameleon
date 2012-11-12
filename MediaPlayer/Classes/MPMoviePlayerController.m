//
//  MPMoviewPlayerController.m
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import "MPMoviePlayerController.h"
#import "UIInternalMovieView.h"

NSString *const MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = @"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey";

// notifications
NSString *const MPMoviePlayerPlaybackStateDidChangeNotification = @"MPMoviePlayerPlaybackStateDidChangeNotification";
NSString *const MPMoviePlayerPlaybackDidFinishNotification = @"MPMoviePlayerPlaybackDidFinishNotification";
NSString *const MPMoviePlayerLoadStateDidChangeNotification = @"MPMoviePlayerLoadStateDidChangeNotification";
NSString *const MPMovieDurationAvailableNotification = @"MPMovieDurationAvailableNotification";

@implementation MPMoviePlayerController

@synthesize view=_view;
@synthesize loadState=_loadState;
@synthesize contentURL=_contentURL;
@synthesize controlStyle=_controlStyle;
@synthesize movieSourceType=_movieSourceType;
@synthesize backgroundView;
@synthesize playbackState=_playbackState;
@synthesize repeatMode=_repeatMode;
@synthesize shouldAutoplay;
@synthesize scalingMode=_scalingMode;

// MPMediaPlayback Attributes
@synthesize isPreparedToPlay = _isPreparedToPlay;
@synthesize currentPlaybackRate = _currentPlaybackRate;
@synthesize currentPlaybackTime = _currentPlaybackTime;

///////////////////////////////////////////////////////////////////////////////
//
- (void)setScalingMode:(MPMovieScalingMode)scalingMode
{
    _scalingMode = scalingMode;
    movieView.scalingMode = scalingMode;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)setRepeatMode:(MPMovieRepeatMode)repeatMode
{
    _repeatMode = repeatMode;
    [movie setAttribute: [NSNumber numberWithBool: repeatMode == MPMovieRepeatModeOne]
                 forKey: QTMovieLoopsAttribute];
}


///////////////////////////////////////////////////////////////////////////////
//
- (NSTimeInterval)duration
{
    QTTime time = [movie duration];
    NSTimeInterval interval;
    
    if (QTGetTimeInterval(time, &interval))
        return interval;
    else
        return 0.0;
}


///////////////////////////////////////////////////////////////////////////////
//
- (UIView*)view
{
    return movieView;
}

#pragma mark - notifications



///////////////////////////////////////////////////////////////////////////////
//
- (void)didEndOccurred: (NSNotification*)notification
{
    if (notification.object != movie)
        return;

    _playbackState = MPMoviePlaybackStateStopped;
        
    NSNumber *stopCode = [NSNumber numberWithInteger:MPMovieFinishReasonPlaybackEnded];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: stopCode
                                                         forKey: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerPlaybackDidFinishNotification
                                                        object: self
                                                      userInfo: userInfo];
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)loadStateChangeOccurred: (NSNotification*)notification
{
    if (notification.object != movie)
        return;
    
    [self updateLoadState];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerLoadStateDidChangeNotification
                                                        object: self];
}

#pragma mark - constructor/destructor

///////////////////////////////////////////////////////////////////////////////
//
- (id)initWithContentURL:(NSURL *)url
{
    self = [super init];
    if (self) 
    {
        _contentURL = [url retain];
        _loadState = MPMovieLoadStateUnknown;
        _controlStyle = MPMovieControlStyleDefault;
        _movieSourceType = MPMovieSourceTypeUnknown;
        _playbackState = MPMoviePlaybackStateStopped;
        _repeatMode = MPMovieRepeatModeNone;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(loadStateChangeOccurred:)
                                                     name: QTMovieLoadStateDidChangeNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didEndOccurred:)
                                                     name: QTMovieDidEndNotification
                                                   object: nil];

        NSError *error = nil;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    url, QTMovieURLAttribute,
                                    [NSNumber numberWithBool:YES], QTMovieOpenForPlaybackAttribute,
                                    [NSNumber numberWithBool:YES], QTMovieOpenAsyncOKAttribute,
                                    [NSNumber numberWithBool:YES], QTMovieOpenAsyncRequiredAttribute,
                                    nil];
        movie = [[QTMovie alloc] initWithAttributes:attributes error:&error];
        movieView = [[UIInternalMovieView alloc] initWithMovie: movie];
        if (error) {
            NSLog(@"%@", error);
        }
        
        self.scalingMode = MPMovieScalingModeAspectFit;
        
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [_view release];
    [super dealloc];
}


#pragma mark - MPMediaPlayback


///////////////////////////////////////////////////////////////////////////////
//
- (void)play
{
    [movie play];
    _playbackState = MPMoviePlaybackStatePlaying;
    
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)pause
{
    [movie stop];
    _playbackState = MPMoviePlaybackStatePaused;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackStateDidChangeNotification
                                                        object:self];
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)prepareToPlay {
    // Do nothing
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)stop
{
    [movie stop];
    _playbackState = MPMoviePlaybackStateStopped;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackStateDidChangeNotification
                                                        object:self];
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)beginSeekingBackward
{
    NSLog(@"beginSeekingBackward is not implemented.");
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)beginSeekingForward
{
    NSLog(@"beginSeekingForward is not implemented.");
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)endSeeking
{
    NSLog(@"endSeeking is not implemented.");
}

///////////////////////////////////////////////////////////////////////////////
//
- (NSTimeInterval)currentPlaybackTime
{
    if (movie) {
        NSTimeInterval currentTime;
        if (QTGetTimeInterval(movie.currentTime, &currentTime)) {
            return currentTime;
        }
    }
    return (NSTimeInterval)0;
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    if (movie) {
        [movie setCurrentTime:QTMakeTimeWithTimeInterval(currentPlaybackTime)];
    }
}

///////////////////////////////////////////////////////////////////////////////
//
- (float)currentPlaybackRate
{
    if (movie) {
        return movie.rate;
    } else {
        return 0;
    }
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)setCurrentPlaybackRate:(float)currentPlaybackRate
{
    if (movie) {
        [movie setRate:currentPlaybackRate];
    }
}

#pragma mark - Pending

- (void) setShouldAutoplay:(BOOL)shouldAutoplay {
    NSLog(@"[CHAMELEON] MPMoviePlayerController.shouldAutoplay not implemented");
}

- (UIView*) backgroundView {
    NSLog(@"[CHAMELEON] MPMoviePlayerController.backgroundView not implemented");
    return nil;
}

#pragma mark - Private

- (void)updateLoadState
{
    long loadState = [[movie attributeForKey: QTMovieLoadStateAttribute] longValue];
    NSLog(@"updateLoadState: %d", loadState);
    
    if (loadState <= QTMovieLoadStateError) {
        NSLog(@"woo");
        NSNumber *stopCode = [NSNumber numberWithInteger:MPMovieFinishReasonPlaybackError];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject: stopCode
                                                             forKey: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        
        // if there's a loading error we generate a stop notification
        [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerPlaybackDidFinishNotification
                                                            object: self
                                                          userInfo: userInfo];
        
        _loadState = MPMovieLoadStateUnknown;
        return;
    }

    if (loadState >= QTMovieLoadStatePlaythroughOK) {
        _loadState = MPMovieLoadStatePlaythroughOK;
    } else if (loadState >= QTMovieLoadStatePlayable) {
        if (_loadState == MPMovieLoadStateUnknown) {
            // we have the meta data, so post the duration available notification
            [[NSNotificationCenter defaultCenter] postNotificationName: MPMovieDurationAvailableNotification
                                                                object: self];            
        }
        _loadState = MPMovieLoadStatePlayable;
    } else if (loadState >= QTMovieLoadStateLoaded) {
        _loadState = MPMovieLoadStateUnknown;
//        // we have the meta data, so post the duration available notification
//        [[NSNotificationCenter defaultCenter] postNotificationName: MPMovieDurationAvailableNotification
//                                                            object: self];
    } else if (loadState >= QTMovieLoadStateLoading) {
        _loadState = MPMovieLoadStateUnknown;
    }
}


@end
