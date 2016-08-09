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
        static let APIHost3 = "dropbox.com"
        static let APIPath = "/2"
        static let APIPath1 = "/1"
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
        static let ClientId = "client_id"
        static let ResponseType = "response_type"
        static let RedirectURI = "redirect_uri"
    }
   
    // MARK: Dropbox Parameter Values
    struct DropboxParameterValues {
        
        static let ClientID = "syu526a8tu8szjx"
        static let ResponseType = "token"
        static let RedirectURI = "https://www.google.com"
        
    }
    struct JSONRequestKeys {
        
        static let Path = "path"
        static let Autorename="autorename"
        static let Mode="mode"
        static let Tag=".tag"
    }
    
    struct JSONResponseKeys {
        static let Entries = "entries"
        static let Name = "name"
        static let Path = "path_lower"
        static let Id = "id"
        static let Size = "size"
        static let Autorename="true"
        static let Overwrite="overwrite"
    }
    
    
}


    