//
//  Informations.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//

import SwiftUI

//変数を定義
struct Informations: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @State var isSaved = false
    
    @State var datas = ["item1", "item2", "item3"]
    @State var itemSelection:String?
    
    var body: some View {
        NavigationView{
                Form{
                    HStack{
                        Text("入力日時")
                        Text(self.user.date, style: .date)
                    }
                    
                    //DatePicker("入力日時", selection: $user.date)
                    
                    HStack{
                        Text(" I D ")
                        TextField("idを入力してください", text: $user.id)
                    }
                        
                        Picker(selection: $user.selected_hospital,
                                   label: Text("施設")) {
                            ForEach(0..<user.hospitals.count) {
                                Text(self.user.hospitals[$0])
                                     }
                            }
                    
                        
                        
                        Picker(selection: $user.selected_disease,
                                   label: Text("疾患")) {
                            ForEach(0..<user.disease.count) {
                                Text(self.user.disease[$0])
                                    }
                            }
                        
                        HStack{
                            Text("自由記載欄")
                            TextField("", text: $user.free_disease)
                                .keyboardType(.default)
                        }.layoutPriority(1)
                }.navigationTitle("患者情報入力")
                .onAppear(){
                 }
            }
                
            
            Spacer()
            Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("保存")
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
    }
}




/*
struct Informations_Previews: PreviewProvider {
    static var previews: some View {
        Informations()
    }
}
*/
