//
//  ContentView.swift
//  Balene
//
//  Created by CJ Ryan on 12/19/23.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @ObservedObject var api_client = APIClient.shared
    
    // State variables for the user interface
    @State var showingPicker = false
    @State var isLoading : Bool = false
    @State var showError : Bool = false
    
    var body: some View {
        VStack {
            
            if api_client.selectedImage != nil {
                
                Image(uiImage: api_client.selectedImage!)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            
            Button {
                showingPicker = true
                isLoading = false
                print("opening photo library...")
            } label: {
                Text("search image")
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 175, height: 50, alignment: .center)
                            .foregroundColor(.blue)
                    )
            }.padding()
            
            
            if api_client.results != nil {
                SearchResultsView(results: api_client.results!)
            }
        }
        .sheet(isPresented: $showingPicker) {
            ImagePickerView(isPickerShowing: $showingPicker)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
