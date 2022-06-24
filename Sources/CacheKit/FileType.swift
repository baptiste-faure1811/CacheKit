//
//  FileType.swift
//  
//
//  Created by Baptiste Faure on 24/06/2022.
//

public enum FileType {
    case image
    case document

    public var fileExtension: String {
        switch self {
        case .image: return ".jpeg"
        case .document: return ".pdf"
        }
    }

    public var directory: String {
        switch self {
        case .image: return "images"
        case .document: return "documents"
        }
    }
}
