import Foundation
import AVFoundation

class StreamingResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    private var activeTasks: [AVAssetResourceLoadingRequest: Task<Void, Never>] = [:]
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        
        // 1. Swap custom scheme (e.g. streaming://) back to http/https
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = "http" // Or pass the original scheme in some way
        
        guard let originalURL = components?.url else { return false }
        
        // 2. Start AsyncSequence Task
        let task = Task {
            await handleRequest(loadingRequest, url: originalURL)
        }
        
        activeTasks[loadingRequest] = task
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        activeTasks[loadingRequest]?.cancel()
        activeTasks.removeValue(forKey: loadingRequest)
    }
    
    private func handleRequest(_ loadingRequest: AVAssetResourceLoadingRequest, url: URL) async {
        guard let dataRequest = loadingRequest.dataRequest else { return }
        
        var request = URLRequest(url: url)
        
        // Handle Range request if specified by AVPlayer
        let offset = dataRequest.requestedOffset
        let length = Int64(dataRequest.requestedLength)
        let end = offset + length - 1
        
        if dataRequest.requestsAllDataToEndOfResource {
             request.addValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
        } else {
             request.addValue("bytes=\(offset)-\(end)", forHTTPHeaderField: "Range")
        }
        
        do {
            // Using AsyncSequence: URLSession.bytes
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            
            // Fill content info
            if let httpResponse = response as? HTTPURLResponse {
                if let infoRequest = loadingRequest.contentInformationRequest {
                    infoRequest.contentType = httpResponse.mimeType
                    infoRequest.contentLength = httpResponse.expectedContentLength
                    infoRequest.isByteRangeAccessSupported = true
                }
            }
            
            var buffer = Data()
            let chunkSize = 64 * 1024 // 64KB segments
            
            for try await byte in bytes {
                if Task.isCancelled { break }
                
                buffer.append(byte)
                
                if buffer.count >= chunkSize {
                    dataRequest.respond(with: buffer)
                    buffer.removeAll(keepingCapacity: true)
                }
            }
            
            // Send remaining buffer
            if !buffer.isEmpty {
                dataRequest.respond(with: buffer)
            }
            
            loadingRequest.finishLoading()
            
        } catch {
            if !Task.isCancelled {
                loadingRequest.finishLoading(with: error)
            }
        }
    }
}
