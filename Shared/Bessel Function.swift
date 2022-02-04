//
//  Bessel Functions.swift
//  Homework 2: Errors in Spherical Bessel Functions
//
//  Created by Matthew Malaker on 2/2/22.
//

import Foundation


class Bessel_Function: NSObject, ObservableObject {

    
    
    //Calculate the 0th order Bessel J function at x
    /// - Parameters:
    ///     - x: The value the bessel function is calculated at
    /// - Returns:
    ///     - The value of the 0th order bessel function at x (Double)
    func besselJ0(x:Double)-> Double{
        return sin(x)/x
    }
    
    
    
    //Calculate the 1st order Bessel J function at x
    /// - Parameters:
    ///     - x: The value the bessel function is calculated at
    /// - Returns:
    ///     - The value of the 1st order bessel function at x (Double)
    func besselJ1(x:Double)-> Double{
        return (sin(x)/pow(x,2))-(cos(x)/x)
    }
    //Calculate the 0th order Neumann n function at x
    /// - Parameters:
    ///     - x: The value the neumann function is calculated at
    /// - Returns:
    ///     - The value of the 0th order neumann function at x (Double)
    func neumannN0(x: Double)->Double{
        return -1*cos(x)/x
    }
    //Calculate the 1st order Neumann n function at x
    /// - Parameters:
    ///     - x: The value the neumann function is calculated at
    /// - Returns:
    ///     - The value of the 1st order neumann function at x (Double)
    func neumannN1(x: Double)->Double{
        return (-1*cos(x)/pow(x,2))-(sin(x)/x)
    }
     
    
    
    //Calculate the l+1th order Bessel j function at x. Used in the upward recursion relation
    /// - Parameters:
    ///     - x: The value the neumann function is calculated at
    ///     - l: The order of the first function Jl
    ///     - Jl: The value of Jl(x)
    ///     - JlMinusOne: The value of Jl-1(x)
    ///  - Returns:
    ///     - The value of the l+1th order bessel function at x (double)
    func BesselJLPlusOne(l: Int, x: Double,Jl: Double, JlMinusOne: Double)->Double{
        return((((2*Double(l))+1)/x)*(Jl)-JlMinusOne)
    }
    //Calculate the l-1th order Bessel j function at x. Used in the downward recursion relation
    /// - Parameters:
    ///     - x: The value the neumann function is calculated at
    ///     - l: The order of the first function Jl
    ///     - Jl: The value of Jl(x)
    ///     - JlPlusOne: The value of Jl+1(x)
    ///  - Returns:
    ///     - The value of the l-1th order bessel function at x (double)
    func BesselJMinusOne(l: Int, x:Double, Jl: Double, JlPlusOne: Double)->Double{
        return (((((2*Double(l))+1)/x)*Jl)-JlPlusOne)
    }
    
    
    //Calculate the Lth order Bessel j function at x using the upward recursion relation
    //Depends on the besselJ0, besselJ1, and BesselJPlusOne functions to work.
    /// - Parameters:
    ///     - x: The value the neumann function is calculated at
    ///     - l: The order of the first function Jl
    ///  - Returns:
    ///     - The value of the Lth order bessel function at x (double) via upward recursion
    func besselJUpwardRecursion(L: Int, x: Double)->Double{
        var jValues = [Double](repeating: 0.0, count: L+1)
        //The smallest L we can calculate with recursion is 2, so the function should only call the recursion if the called Lth besselJ is in the range where the recursion is needed
        if L>=2{
            jValues[0] = besselJ0(x: x)
            jValues[1] = besselJ1(x: x)
            
            //Looping from 1 to L-1 to keep convention of calculating j_(l+1)
            //The final result will be in jValues[L]
            for l in stride(from: 1, through: L-1, by: 1){
                jValues[l+1] = (BesselJLPlusOne(l: l, x: x, Jl: jValues[l], JlMinusOne: jValues[l-1]))
            }
            return jValues[L]
        }
        else{
            return 0
        }
    }
    
    
    /* Calculate Bessel functions using downward recursion */
    /// calculateDownwardRecursion
    /// - Parameters:
    ///   - x: x
    ///   - L: Order of Bessel Function
    ///
    ///               2l
    ///     J       (x)  =   ------ J  (x)   -  J        (x)
    ///      l - 1              x       l             l + 1
    ///
    ///  - Returns:
    ///     - The value of the Lth order bessel function at x (double) using downward recursion
    
    func besselJDownwardRecursion(L: Int, x:Double)->Double{
        var jValues = [Double](repeating: 1.0, count: L+1)//Make the array longer than it needs to be to start for safety purpose
        var scaleFactor = besselJ0(x: x)
        //The smallest L we can calculate with recursion is 2, so the function should only call the recursion if the called Lth besselJ is in the range where the recursion is needed
        if L>=2{
//            jValues[0] = besselJ0(x: x)
//            jValues[1] = besselJ1(x: x)
            //The value L is the order of the returned bessel function and is the end of the JValues array
            jValues[L-1] = 1.0
            jValues[L] = 1.0
            for l in stride(from: L-1, through: 1, by: 1){
                jValues[l-1]=BesselJMinusOne(l: l, x: x, Jl: jValues[l], JlPlusOne: jValues[l+1])
                print(jValues[l-1])
            }
            scaleFactor = besselJ0(x: x)/jValues[0]
            return(jValues[L]*scaleFactor)
            
    }
        else{
            return 0
        }
    
}
    //The homework requests calculating the first 25 bessel values for 3 values of x with both methods
    //These calculations are each independent and can thus be threaded. The goal is to make a function that spits out the first L of bessel J functions of a particular method at point x. This allows for task managers to be used to manage each x and method
    //We already did this. The recursion function calculates the value fo each bessel function between up to the desired L value, so we can simply copy that function and change the return to the jValues array.
    
    
    
    //Calculate and return the values of all bessel J functions between 0 and L via upward recursion
    /// - Parameters:
    ///     - L: The highest order desired bessel function
    ///     - x: The vale at which the functions are calculated
    /// - Returns:
    ///     - The value of each bessel function between order 0 and L [Double]
//    func besselJUpwardList(L: Int, x: Double)-> Array<Double>{
//        var jValues = [Double]()
//        //The smallest L we can calculate with recursion is 2, so the function should only call the recursion if the called Lth besselJ is in the range where the recursion is needed
//        if L>=2{
//            jValues.append(besselJ0(x: x))
//            jValues.append(besselJ1(x: x))
//
//            //Looping from 1 to L-1 to keep convention of calculating j_(l+1)
//            //The final result will be in jValues[L]
//            for l in stride(from: 1, through: L-1, by: 1){
//                jValues.append(BesselJLPlusOne(l: l, x: x, Jl: jValues[l], JlMinusOne: jValues[l-1]))
//            }
//            return jValues
//        }
//        else{
//            return [0]
//        }
//    }
    
    
    //This one is oging to be a buit different than the upward calculating one. The function we created assumes a unitary value for JL, so the downward recursion only calculates one useful value in its operation. We will have to call that function N times to generate our list. At least, I think we do.
    
    //Calculate and return the values of all bessel J functions between 0 and L via downward recursion
    /// - Parameters:
    ///     - L: The highest order desired bessel function
    ///     - x: The vale at which the functions are calculated
    /// - Returns:
    ///     - The value of each bessel function between order 0 and L [Double]
//    func besselJDownwardList(L: Int, x: Double)-> Array<Double>{
//        if L>=2{
//            var jOutput = [Double]()
//            jOutput.append(besselJ0(x: x))
//            jOutput.append(besselJ1(x: x))
//            for l in stride(from: 2, through: L, by: 1){
//                jOutput[l] = besselJDownwardRecursion(L: l, x: x)
//            }
//            return jOutput
//
//    }
//        else{
//        return [0.0]
//            }
//
//    }
    
    
}
