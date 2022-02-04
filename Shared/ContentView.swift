//
//  ContentView.swift
//  Shared
//
//  Created by Matthew Malaker on 2/2/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bessel = Bessel_Function()
    @State var upward01 = ""
    @State var upward1 = ""
    @State var upward10 = ""
    @State var downward01 = ""
    @State var downward1 = ""
    @State var downward10 = ""
    @State var jValueString = ""
    @State var xValueString = ""
    @State var stepSizeValueString = ""
    @State var editorText = ""
    @State var testBesselString = ""
    @State var besselValuesUpward:  (l: Int, sortedCombinedTaskResults: [(xValue: Double, besselJValue: Double)]) = (l: 0, sortedCombinedTaskResults: [])
    @State var besselValuesDownward:  (l: Int, sortedCombinedTaskResults: [(xValue: Double, besselJValue: Double)]) = (l: 0, sortedCombinedTaskResults: [])

    
    
    var body: some View {
        //We are going to use an updating document field to display the data.
        HStack{
        VStack{
            HStack{
                Text("Enter J")
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
                TextField("",text: $jValueString)
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
            }
            HStack{
                Text("Enter x")
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
                TextField("",text: $xValueString)
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
            }
            HStack{
                Text("Enter Step Size")
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
                TextField("",text: $stepSizeValueString)
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
            }
            
            //Calculate Button
            Button("Calculate", action: {Task.init{besselValuesUpward = await calculateUpwardBesselValues(l: Int(jValueString) ?? 2, xMax: Double(xValueString) ?? 0.1, stepSize: Double(stepSizeValueString) ?? 0.1)}; Task.init{besselValuesDownward = await calculateDownwardBesselValues(l: Int(jValueString) ?? 2, xMax: Double(xValueString) ?? 0.1, stepSize: Double(stepSizeValueString) ?? 0.1)}; editorText = generateText(upwardValues: besselValuesUpward, downwardValues: besselValuesDownward)})
                .padding(.bottom)
                .padding()
            Button("Display", action: {editorText = generateText(upwardValues: besselValuesUpward, downwardValues: besselValuesDownward)})
                .padding(.bottom)
                .padding()
        }
            TextEditor(text: $editorText)
        }
            
//            //Calculate Button
//            Button("TEST", action: {testBesselString = String(bessel.besselJDownwardRecursion(L: Int(jValueString) ?? 2 , x: Double(xValueString) ?? 0.1)); print(testBesselString)})
//                .padding(.bottom)
//                .padding()
        
        
    }
    
    //FUNCTION BANK
    //Calculate the first 25 jl(x) for x={0.1,1,10) via upward and downward recursion
    //We need to return at minimum the values of the bessel function at the desired values of x of a bessel function l. l, x, and the result should be returned. This makes the return well formatted
    //importantly, we need tobe able to read the function. This is more difficult than you may think
    
    //This function takes the upward and downward values from sortedCombinedTaskResults and returns the text for the editor as a string with multiple lines.
    func generateText(upwardValues: (l: Int, sortedCombinedTaskResults: [(xValue: Double, besselJValue: Double)]),downwardValues: (l: Int, sortedCombinedTaskResults: [(xValue: Double, besselJValue: Double)]))->String{
        var outputString = ""
        var xValuesToPrint: [Double] = []
        var besselUpValuesToPrint: [Double] = []
        var besselDownValuesToPrint: [Double] = []
        
        for i in stride(from: 0, to: upwardValues.sortedCombinedTaskResults.count, by: 1){
            //I have these arrays so I can read the code. I suppose I could use text wrapping as well
            xValuesToPrint.append(upwardValues.sortedCombinedTaskResults[i].xValue)
            besselUpValuesToPrint.append(upwardValues.sortedCombinedTaskResults[i].besselJValue)
            besselDownValuesToPrint.append(downwardValues.sortedCombinedTaskResults[i].besselJValue)
            outputString += String(format: "x = %f, Downward, %7.5e, Upward, %7.5e\n", "j= ",upwardValues.l,"x= ",xValuesToPrint[i]," Upward Recursion: ",besselUpValuesToPrint[i],"Downward Recursion: ",besselDownValuesToPrint[i])
        }
    
        
        
        return outputString
    }
    
    
    //Use a task group to calculate the results for upward recursion.
    /// - Parameters:
    ///  - l: Int : function order
    ///  - xMax:(Double) the maximum x value to calculate to
    ///  - stepSize: (Double) the distance in x between calculations
    func calculateUpwardBesselValues(l: Int,xMax: Double, stepSize: Double) async -> (l: Int, sortedCombinedTaskResults: [(xValue: Double, besselJValue: Double)]){
        
        //Coding task groups is the equivalent of diving into an avalanche on purpose
        let combinedBesselJResultsUpward = await withTaskGroup(of: (xValue: Double, besselJValue: Double).self, returning: [(xValue: Double, besselJValue: Double)].self, body: { taskGroup in
            
            //Have fun
            
            for x in stride(from: 0+stepSize, through: xMax, by: stepSize){
                taskGroup.addTask{
                    var passedX: Double = 0.0
                    var calculatedBesselJ: Double = 0.0
                    calculatedBesselJ = await bessel.besselJUpwardRecursion(L: l, x: x)
                    passedX = x
                    return(xValue: passedX, besselJValue: calculatedBesselJ)
                                }
                
                           }
            
            var combinedTaskResults: [(xValue: Double, besselJValue: Double)] = []
            
            for await result in taskGroup{
                combinedTaskResults.append(result)
            }
            
            return combinedTaskResults
        })
        
        let sortedCombinedTaskResults = combinedBesselJResultsUpward.sorted(by: { $0.0 < $1.0 })
        
        for item in sortedCombinedTaskResults{
            
            print(item)
            
            // Display the sorted text in the GUI
//            await updateGUI(text: "\(item.1)")
            
        }
        
        return(l: l, sortedCombinedTaskResults: sortedCombinedTaskResults)
        
    }
    //Use a task group to calculate the results for upward recursion.
    /// - Parameters:
    ///  - l: Int : function order
    ///  - xMax:(Double) the maximum x value to calculate to
    ///  - stepSize: (Double) the distance in x between calculations
    func calculateDownwardBesselValues(l: Int,xMax: Double, stepSize: Double) async -> (l: Int, sortedCombinedTaskResults: [(xValue: Double, besselJValue: Double)]){
        
        //Perhaps a rockslide would be a better analogy
        let combinedBesselJResultsDownward = await withTaskGroup(of: (xValue: Double, besselJValue: Double).self, returning: [(xValue: Double, besselJValue: Double)].self, body: { taskGroup in
            
            //You won't have fun. I was being facetious before.
            for x in stride(from: 0+stepSize, through: xMax, by: stepSize){
                taskGroup.addTask{
                    var passedX: Double = 0.0
                    var calculatedBesselJ: Double = 0.0
                    calculatedBesselJ = await bessel.besselJDownwardRecursion(L: l, x: x)
                    passedX = x
                    return(xValue: passedX, besselJValue: calculatedBesselJ)
                                }
                
                           }
            
            var combinedTaskResults: [(xValue: Double, besselJValue: Double)] = []
            
            for await result in taskGroup{
                combinedTaskResults.append(result)
            }
            
            return combinedTaskResults
        })
        
        let sortedCombinedTaskResults = combinedBesselJResultsDownward.sorted(by: { $0.0 < $1.0 })
        
        for item in sortedCombinedTaskResults{
            
            print(item)
            
            // Display the sorted text in the GUI
//            await updateGUI(text: "\(item.1)")
            
        }
        
        return(l: l, sortedCombinedTaskResults: sortedCombinedTaskResults)
        
    }

    
    
    
//    func calculateBesselValues() async-> Array<Array<Array<Double>>>{
//        //initialize taskgroup
//        let jValuesUpward = await withTaskGroup(of: (Double, [Double]).self, returning: [[Double]].self, body: {taskGroup in
//            //Initialize each task in desired plot range
//            for i in [0.1,1,10] {
//                taskGroup.addTask {
//                    //Create return value. This is a complex computation, hence the threading
//                    let values = await bessel.besselJUpwardList(L: 25, x: i)
//                    return (i,values)
//                    }
//                }
//            //Take results as they come in and assign them to their proper place
//            //We do not know the order these tasks will finish in, so we use a tuple to assign each result its value
//            var interimResults = [[0.0]]
//            //reordering results as they come in
//            for await result in taskGroup{
//                if result.0==0.1{
//                    interimResults[0]=result.1
//                }
//                if result.0==1{
//                    interimResults[1]=result.1
//                }
//                if result.0==10{
//                    interimResults[2]=result.1
//                }
//            }
//
//            return interimResults
//        })
//
//        let jValuesDownward = await withTaskGroup(of: (Double, [Double]).self, returning: [[Double]].self, body: {taskGroup in
//            //Initialize each task in desired plot range
//            for i in [0.1,1,10] {
//                taskGroup.addTask {
//                    //Create return value. This is a complex computation, hence the threading
//                    let values = await bessel.besselJDownwardList(L: 25, x: i)
//                    return (i,values)
//                    }
//                }
//            //Take results as they come in and assign them to their proper place
//            //We do not know the order these tasks will finish in, so we use a tuple to assign each result its value
//            var interimResults = [[0.0]]
//            //reordering results as they come in
//            for await result in taskGroup{
//                if result.0==0.1{
//                    interimResults[0]=result.1
//                }
//                if result.0==1{
//                    interimResults[1]=result.1
//                }
//                if result.0==10{
//                    interimResults[2]=result.1
//                }
//            }
//
//            return interimResults
//        })
//
//        return([jValuesUpward,jValuesDownward])
//        }
        
//    func convertArrayToStrings(besselValues: [[[Double]]]){
//        let upwardValues = besselValues[0]
//        let downwardValues = besselValues[1]
//        let upward01Values = upwardValues[0]
//        let upward1Values = upwardValues[1]
//        let upward10Values = upwardValues[2]
//        let downward01Values = downwardValues[0]
//        let downward1Values = downwardValues[1]
//        let downward10Values = downwardValues[2]
//        upward01 = upward01Values.description
//        upward1 = upward1Values.description
//        upward10 = upward10Values.description
//        downward01 = downward01Values.description
//        downward1 = downward1Values.description
//        downward10 = downward10Values.description
//    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
