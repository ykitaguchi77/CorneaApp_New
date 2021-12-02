//
//  Informations.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//

import SwiftUI
import CoreData
import CryptoKit

//変数を定義
struct SavedData: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.newdate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {    // ナビゲーションバーを表示する為に必要
            VStack(spacing:0){
                Text("Saved Data")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                //saved dataをリスト形式で表示
                //HashID: SHA-256を使用。"yyyymmdd-ID"をハッシュ化。
                //CoreDataのAttributeを追加するときには、スマホ内の保存データを全て削除すること
                List {
                    ForEach(items) {item in
                        Text("Date: \(item.newdate!, formatter: itemFormatter), ID: \(item.newid!), Hospitals: \(item.newhospitals!), Disease: \(item.newdisease!)")
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    /// ナビゲーションバーの左にEditボタンを配置
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }


                }
            }
        }
    }
    


    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
