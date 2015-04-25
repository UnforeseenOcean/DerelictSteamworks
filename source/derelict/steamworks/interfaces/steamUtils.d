﻿module derelict.steamworks.interfaces.steamUtils;

import derelict.steamworks.types;

extern(C++) interface ISteamUtils
{
    // return the number of seconds since the user 
    uint32 GetSecondsSinceAppActive();
    uint32 GetSecondsSinceComputerActive();
    
    // the universe this client is connecting to
    EUniverse GetConnectedUniverse();
    
    // Steam server time - in PST, number of seconds since January 1, 1970 (i.e unix time)
    uint32 GetServerRealTime();
    
    // returns the 2 digit ISO 3166-1-alpha-2 format country code this client is running in (as looked up via an IP-to-location database)
    // e.g "US" or "UK".
    const char *GetIPCountry();
    
    // returns true if the image exists, and valid sizes were filled out
    bool GetImageSize( int iImage, uint32 *pnWidth, uint32 *pnHeight );
    
    // returns true if the image exists, and the buffer was successfully filled out
    // results are returned in RGBA format
    // the destination buffer size should be 4 * height * width * sizeof(char)
    bool GetImageRGBA( int iImage, uint8 *pubDest, int nDestBufferSize );
    
    // returns the IP of the reporting server for valve - currently only used in Source engine games
    bool GetCSERIPPort( uint32 *unIP, uint16 *usPort );
    
    // return the amount of battery power left in the current system in % [0..100], 255 for being on AC power
    uint8 GetCurrentBatteryPower();
    
    // returns the appID of the current process
    uint32 GetAppID();
    
    // Sets the position where the overlay instance for the currently calling game should show notifications.
    // This position is per-game and if this function is called from outside of a game context it will do nothing.
    void SetOverlayNotificationPosition( ENotificationPosition eNotificationPosition );
    
    // API asynchronous call results
    // can be used directly, but more commonly used via the callback dispatch API (see steam_api.h)
    bool IsAPICallCompleted( SteamAPICall_t hSteamAPICall, bool *pbFailed );
    ESteamAPICallFailure GetAPICallFailureReason( SteamAPICall_t hSteamAPICall );
    bool GetAPICallResult( SteamAPICall_t hSteamAPICall, void *pCallback, int cubCallback, int iCallbackExpected, bool *pbFailed );
    
    // this needs to be called every frame to process matchmaking results
    // redundant if you're already calling SteamAPI_RunCallbacks()
    void RunFrame();
    
    // returns the number of IPC calls made since the last time this function was called
    // Used for perf debugging so you can understand how many IPC calls your game makes per frame
    // Every IPC call is at minimum a thread context switch if not a process one so you want to rate
    // control how often you do them.
    uint32 GetIPCCallCount();
    
    // API warning handling
    // 'int' is the severity; 0 for msg, 1 for warning
    // 'const char *' is the text of the message
    // callbacks will occur directly after the API function is called that generated the warning or message
    void SetWarningMessageHook( SteamAPIWarningMessageHook_t pFunction );
    
    // Returns true if the overlay is running & the user can access it. The overlay process could take a few seconds to
    // start & hook the game process, so this function will initially return false while the overlay is loading.
    bool IsOverlayEnabled();
    
    // Normally this call is unneeded if your game has a constantly running frame loop that calls the 
    // D3D Present API, or OGL SwapBuffers API every frame.
    //
    // However, if you have a game that only refreshes the screen on an event driven basis then that can break 
    // the overlay, as it uses your Present/SwapBuffers calls to drive it's internal frame loop and it may also
    // need to Present() to the screen any time an even needing a notification happens or when the overlay is
    // brought up over the game by a user.  You can use this API to ask the overlay if it currently need a present
    // in that case, and then you can check for this periodically (roughly 33hz is desirable) and make sure you
    // refresh the screen with Present or SwapBuffers to allow the overlay to do it's work.
    bool BOverlayNeedsPresent();
    
    version(_PS3){
        void PostPS3SysutilCallback( uint64_t status, uint64_t param, void* userdata ) = 0;
        bool BIsReadyToShutdown() = 0;
        bool BIsPSNOnline() = 0;
        
        // Call this with localized strings for the language the game is running in, otherwise default english
        // strings will be used by Steam.
        void SetPSNGameBootInviteStrings( const char *pchSubject, const char *pchBody );
    }
    else
    {
        // Asynchronous call to check if an executable file has been signed using the public key set on the signing tab
        // of the partner site, for example to refuse to load modified executable files.  
        // The result is returned in CheckFileSignature_t.
        //   k_ECheckFileSignatureNoSignaturesFoundForThisApp - This app has not been configured on the signing tab of the partner site to enable this function.
        //   k_ECheckFileSignatureNoSignaturesFoundForThisFile - This file is not listed on the signing tab for the partner site.
        //   k_ECheckFileSignatureFileNotFound - The file does not exist on disk.
        //   k_ECheckFileSignatureInvalidSignature - The file exists, and the signing tab has been set for this file, but the file is either not signed or the signature does not match.
        //   k_ECheckFileSignatureValidSignature - The file is signed and the signature is valid.
        SteamAPICall_t CheckFileSignature( const char *szFileName );
    }
    
    // Activates the Big Picture text input dialog which only supports gamepad input
    bool ShowGamepadTextInput( EGamepadTextInputMode eInputMode, EGamepadTextInputLineMode eLineInputMode, const char *pchDescription, uint32 unCharMax, const char *pchExistingText );
    
    // Returns previously entered text & length
    uint32 GetEnteredGamepadTextLength();
    bool GetEnteredGamepadTextInput( char *pchText, uint32 cchText );
    
    // returns the language the steam client is running in, you probably want ISteamApps::GetCurrentGameLanguage instead, this is for very special usage cases
    const char *GetSteamUILanguage();
    
    // returns true if Steam itself is running in VR mode
    bool IsSteamRunningInVR();
}