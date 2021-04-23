//
//  Informations.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//

import SwiftUI

//変数を定義



struct Informations: View {
    @EnvironmentObject var user: User
    @State private var backToMain = false  //保存してメインに戻るボタン
    @State var isSaved = false

    var body: some View {
        NavigationView{
                Form{
                    DatePicker("入力日時", selection: $user.date)
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
                        }
                }.navigationTitle("患者情報入力")
            }
                
            
            Spacer()
            Button(action: {
                    self.backToMain = true /*またはself.show.toggle() */
            }) {
                Text("保存")
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$backToMain) {
                ContentView()
            }
    }
}


struct Informations_Previews: PreviewProvider {
    static var previews: some View {
        Informations()
    }
}

