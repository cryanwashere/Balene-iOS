//
//  SearchResultsView.swift
//  Balene
//
//  Created by CJ Ryan on 12/27/23.
//

import SwiftUI

struct SearchResultsView: View {
    
    @State var results : Results
    
    var body : some View {
        VStack {
            
            ScrollView {
                Divider()
                ForEach(results.search_result, id:\.self) { search_result in
                    WikipediaPageView(search_result: search_result)
                    Divider()
                }
                
            }
            
        }
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(results:
                            Results(search_result:
                                        [
                                            SearchResult(type: "image", image_source: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Dew_2.jpg/240px-Dew_2.jpg", page_source: "https://wikipedia.org/wiki/Surface_tension"),
                                            SearchResult(type: "image", image_source: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Iris_versicolor_FWS.jpg/200px-Iris_versicolor_FWS.jpg", page_source: "https://wikipedia.org/wiki/Edgar_Anderson"),
                                            SearchResult(type: "image", image_source: "https://upload.wikimedia.org/wikipedia/commons/a/a8/Steganography_original.png", page_source: "https://wikipedia.org/wiki/Steganography")
                                            ])
                                                           
        )
    }
}

struct WikipediaPageView : View {
    
    @State var search_result : SearchResult
    
    @StateObject var wikipedia_client = WikipediaAPIClient()
    
    var body : some View {
        
        VStack{
            if wikipedia_client.wikipediaPageInfo != nil {
                HStack{
                    if wikipedia_client.image != nil {
                        Link(destination: URL(string: wikipedia_client.page_source!)!) {
                            Image(uiImage: wikipedia_client.image!)
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .shadow(radius: 5)
                                //.padding()
                        }
                    }
                    VStack{
                        HStack{
                            Text(wikipedia_client.wikipediaPageInfo!.title)
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text(wikipedia_client.wikipediaPageInfo!.description)
                            Spacer()
                        }
                    }
                    
                }
                .padding()
            }
        }
        
        .onAppear {
            if wikipedia_client.wikipediaPageInfo == nil {
                wikipedia_client.getPageInfo(page_url: search_result.page_source, image_url: search_result.image_source)
            }
        }
    }
}

class WikipediaAPIClient : ObservableObject {
    
    @Published var wikipediaPageInfo : WikipediaPageInfo? = nil
    @Published var image : UIImage? = nil
    @Published var page_source : String? = nil
    
    func getPageInfo(page_url : String, image_url : String?) {
        
        self.page_source = page_url
        
        let page_title = page_url.split(separator: "/").last!
        
        guard let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(page_title)") else { return }
        
        print("fetching wikipedia page data for: \(url.absoluteString)")
        
        // Make a request to the wikipedia API
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let data = data {
                do {
                    //print(String(data: data, encoding: String.Encoding.utf8))
                    let info = try JSONDecoder().decode(WikipediaPageInfo.self, from: data)
                
                    DispatchQueue.main.async {
                        //print(info)
                        
                        self.wikipediaPageInfo = info
                        self.loadImage(image_url : image_url)
                    }
                } catch let error {
                    print("Error decoding data: \(error.localizedDescription) (for \(page_url))")
                }
            }
        }.resume()
    }
    
    func loadImage(image_url : String?) {
        if self.wikipediaPageInfo != nil {
            DispatchQueue.global().async {
                
                var url_string = image_url
                if url_string == nil {
                    return
                    //url_string = self.wikipediaPageInfo!.thumbnail.source
                }
                
                if let url = URL(string:url_string!), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        print("updating loaded image...")
                        let resizedImage = uiImage.resized(to: CGSize(width: 224, height: 224 * (uiImage.size.height / uiImage.size.width)))
                        self.image = resizedImage
                    }
                }
            }
        }
    }
}


// structures that are used to decode responses from the wikipedia API
struct WikipediaPageInfo : Codable {
    let title: String
    let displaytitle: String?
    let extract: String?
    let description: String
    
    let thumbnail : Thumbnail?
    let originalimage : Originalimage?
    let content_urls : Content_urls?
    
    
    struct Thumbnail : Codable {
        let source: String
    }
    struct Originalimage : Codable {
        let source: String
    }
    
    struct Content_urls : Codable {
        let mobile : Mobile
        struct Mobile : Codable {
            let page: String
        }
    }
}
