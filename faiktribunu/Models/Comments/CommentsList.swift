//
//  CommentsList.swift
//  faiktribunu
//
//  Created by Mac on 24.02.2019.
//  Copyright © 2019 Halil İbrahim YÜCE. All rights reserved.
//

import Foundation
import ObjectMapper

public class CommentsList: BaseItem {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let lst = "lst"
    }
    
    // MARK: Properties
    public var lst: [BaseClass]?
    
    // MARK: ObjectMapper Initializers
    /// Map a JSON object to this class using ObjectMapper.
    ///
    /// - parameter map: A mapping from ObjectMapper.
    /// Map a JSON object to this class using ObjectMapper.
    ///
    /// - parameter map: A mapping from ObjectMapper.
    public override func mapping(map: Map) {
        super.mapping(map: map)
        lst <- map[SerializationKeys.lst]
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public override func dictionaryRepresentation() -> [String: AnyObject] {
        var dictionary: [String: Any] = [:]
        if let value = lst { dictionary[SerializationKeys.lst] = value }
        return dictionary as [String : AnyObject] as [String : AnyObject]
    }
    
}

