//
//  ContentView.swift
//  BetterSleep
//
//  Created by Dominique Strachan on 8/14/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeup = defaultWakeTime
    @State private var sleepAmount = 8.0
    
    @State private var selectedCoffeeAmount = 1
    //@State private var coffeeAmount = 1
    let coffeeAmount = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 10) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeup, displayedComponents: .hourAndMinute).labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Desired amount of sleep:")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
//                    Text("Daily coffee intake")
//                        .font(.headline)
                    
                    Picker("Coffee amount:", selection: $selectedCoffeeAmount) {
                        ForEach(coffeeAmount, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .font(.headline)
                    
                    Text(selectedCoffeeAmount == 1 ? "\(selectedCoffeeAmount) cup" : "\(selectedCoffeeAmount) cups")
                    
            
                    
//                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    
                }
                
                Section {
                    Text(calculateBedtime())
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                }header: {
                    Text("Your recommended bedtime is...")
                }
                
            }
            .navigationTitle("BetterSleep")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("OK") {
//
//                }
//            } message: {
//                Text(alertMessage)
//            }
        }
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeup)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(selectedCoffeeAmount))
            let sleepTime = wakeup - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
            
        } catch {
            return "Sorry, there was an issue calculating your bedtime."
        }
    }
    
    //USED FOR CALCULATE BUTTON IN NAV BAR ---> ALERT MESSAGE
//    func calculateBedtime() {
//        do {
//            let config = MLModelConfiguration()
//            let model = try SleepCalculator(configuration: config)
//
//            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeup)
//            let hour = (components.hour ?? 0) * 60 * 60
//            let minute = (components.minute ?? 0) * 60
//
//            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(selectedCoffeeAmount))
//
//            let sleepTime = wakeup - prediction.actualSleep
//            alertTitle = "Your ideal bedtime is..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
//        } catch {
//            alertTitle = "Error"
//            alertMessage = "Sorry, there was a problem calculating your bedtime."
//        }
//
//        showingAlert = true
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
