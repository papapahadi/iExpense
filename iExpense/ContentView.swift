//
//  ContentView.swift
//  iExpense
//
//  Created by Jatin Singh on 27/08/24.
//

import SwiftUI

struct ExpenseItem : Identifiable, Codable {
    var id = UUID()
    let name : String
    let type : String
    let amount : Double
}

@Observable
class Expenses {
    var items = [ExpenseItem](){
        didSet {
            if let encoded = try? JSONEncoder().encode(items){
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init(){
        if let savedItems = UserDefaults.standard.data(forKey: "Items"){
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems){
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var personalExpenses : [ExpenseItem] {
        return expenses.items.filter { $0.type == "Personal" }
    }
    
    var businessExpenses : [ExpenseItem] {
        return expenses.items.filter { $0.type == "Business" }
    }
    
    var body: some View {
        NavigationStack{
            List{
                
                Section{
                    ForEach(personalExpenses){ item in
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                                .foregroundStyle( item.amount < 10 ? .green : item.amount < 100 ? .orange : .pink )
                        }
                    }
                    .onDelete(perform: removeItems)
                }
                
                Section{
                    ForEach(businessExpenses){ item in
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .foregroundStyle( item.amount < 10 ? .green : item.amount < 100 ? .orange : .pink )
                        }
                    }
                    .onDelete(perform: removeItems)
                }
                
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("add expense",systemImage: "plus"){
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense){
                AddView(expenses: expenses)
            }
        }
    }

    func removeItems(at offsets : IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
    
}

#Preview {
    ContentView()
}
