//
//  Constants.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 07/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation

extension DropboxClient
{
    struct Constants {
        
        static let APIScheme = "https"
        static let APIHost1 = "content.dropboxapi.com"
        static let APIHost2 = "api.dropboxapi.com"
        static let APIPath = "/2"
    }
    
    
    struct Methods {
        static let FileUpload = "/files/upload"
        static let FileDownload = "/files/download"
        static let Authorize = "/oauth2/authorize"
        static let ListFolderContents = "/files/list_folder"
        static let DisableAccessToken = "/auth/token/revoke"
    }
    // MARK: Dropbox Parameter Keys
    struct DropboxParameterKeys {
        static let ClientId = "api_key"
        static let ResponseType = "response_type"
    }
    
    // MARK: Dropbox Parameter Values
    struct DropboxParameterValues {
        
        static let ClientID = "syu526a8tu8szjx"
        static let ResponseType = "code"
        
    }
    struct JSONRequestKeys {
        
        static let Path = "path"
        static let folderPath = "/apps/qafilemanager/"
        // static let folderPath = "/apps/qafilemanager/"
           }
    
    struct JSONResponseKeys {
        
       
        static let Entries = "entries"
        static let Name = "name"
        static let Path = "path_lower"
         static let Id = "id"
        static let Size = "size"
    }
    
    
}


    