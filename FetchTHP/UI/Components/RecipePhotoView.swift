//
//  RecipePhotoView.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/16/25.
//

import SwiftUI

struct RecipePhotoView: View {
    let photoURL: URL?

    private let size = 124.0
    private let cornerRadius = 16.0

    var body: some View {
        if let photoURL {
            URLImage(url: photoURL) { content in
                switch content {
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: size, height: size)
                        .cornerRadius(cornerRadius)
                case .failure, .empty:
                    placeholder
                default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    var placeholder: some View {
        Rectangle()
            .foregroundStyle(.gray)
            .frame(width: size, height: size)
            .cornerRadius(cornerRadius)
            .opacity(0.1)
    }
}

#Preview() {
    RecipePhotoView(photoURL: nil)

    RecipePhotoView(photoURL: Recipe.sample.photoURL)
}
