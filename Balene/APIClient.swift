//
//  APIClient.swift
//  Balene
//
//  Created by CJ Ryan on 12/27/23.
//

import Foundation
import UIKit







class APIClient : ObservableObject {
    public static let shared : APIClient = APIClient()
    
    // variable holds the image that is currently being searched
    @Published var selectedImage : UIImage?
    
    // the search results for the most recent search
    @Published var results : Results?
    
    func makeAPIrequest(uiimage: UIImage) {
        
        // clear out the results from the last search
        self.results = nil
       
        print("making API request...")
        
        //self.selectedImage = uiimage
        
        let smaller_image = uiimage.aspectFittedToHeight(100)
        self.selectedImage = smaller_image
        
        // The image needs to be converted to jpeg data so that the API can read it
        guard let imageData = smaller_image.pngData() else {print("failed to convert UIImage to png data");return}
        
        // the API endpoint
        let url = URL(string: "http://209.97.152.154:8000/search_image")!
        
        // create a request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Set the content type
        //request.setValue("image/png", forHTTPHeaderField: "Content-Type")
        
        
        
        
        // Create a FormData object equivalent in Swift
        let formData = NSMutableData()

        // Boundary string for multipart/form-data
        let boundary = "----WebKitFormBoundary\(UUID().uuidString)"
        
        // Append the image data to the FormData object
        formData.append("--\(boundary)\r\n".data(using: .utf8)!)
        formData.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        formData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        formData.append(imageData)
        formData.append("\r\n".data(using: .utf8)!)
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Set the content type with the boundary
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        // Attach the FormData to the request
        request.httpBody = formData as Data
        
        
        
        
        // send the request
        print("sending API request...")
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
            
            print("recieved API response")
            
            // check if there are any errors
            if (error != nil) {
                print("Error: \(error!.localizedDescription)")
            }
            
            do {
                if let responseData = data {
                    
                    print(responseData)
                    let data_string = String(decoding: responseData, as: UTF8.self)
                    print(data_string)
                    
                    let decodedData = try JSONDecoder().decode(Results.self, from: responseData)
                    //print(decodedData)
                    
                    self.results = decodedData
                    
                    
                    
                }
            } catch {
                print("failed to decode response data")
            }
            
        }
        
    }
    
    
}


// Data structures to store the search results
struct SearchResult : Codable, Hashable { 
    let type: String
    let image_source: String?
    let page_source: String
}

struct Results : Codable {
    let search_result: [SearchResult]
}
