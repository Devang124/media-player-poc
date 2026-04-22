//
//  Temp.swift
//  MediaPlayerApp
//
//  Created by Neosoft on 22/04/26.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private func documentURL() -> URL? {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return docURL
    }
    
    private func getImagePath(_ name: String) -> URL? {
        guard let docURL = documentURL() else {
            print("URL not found")
            return nil
        }
        
        let fileURL = docURL.appendingPathComponent(name)
        return fileURL
    }
    
    private func isExist(_ name: String) -> Bool {
        guard let docURL = getImagePath(name) else {
            print("URL not found")
            return false
        }
        
        return FileManager.default.fileExists(atPath: docURL.path)
    }
    
    func saveImage(_ image: UIImage) {
        guard let docURL = documentURL() else {
            print("URL not found")
            return
        }
        
        guard let data = image.pngData() else {
            print("No Data")
            return
        }
        
        do {
            try data.write(to: docURL)
        } catch {
            print(error)
        }
    }
    
    func getImage(_ name: String) -> UIImage? {
        guard let docURL = getImagePath(name) else {
            print("URL not found")
            return nil
        }
        
        if let imageData = try? Data(contentsOf: docURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
}
