// The algorithm that is used to determine the quantitative criterion in the difference of two words
// The algorithm is not my development, I use it in the application
// Example: levenstein(text_1: "milk", text_2: "mitlk") = 1
func levenstain(text_1: String, text_2: String) -> Double {
 
  if text_1.count == 0 || text_2.count == 0 {
    return MAXCOUNTWORDERROR
  } else if abs(text_1.count - text_2.count) >= Int(MAXCOUNTWORDERROR) {
    return MAXCOUNTWORDERROR
  } else {
    let (t, s) = (text_1, text_2)
    let empty = Array<Int>(repeating:0, count: s.count)
    var last = [Int](0...s.count)
    for (i, tLett) in t.enumerated() {
      var cur = [i + 1] + empty
      for (j, sLett) in s.enumerated() {
        cur[j + 1] = tLett == sLett ? last[j] : min(last[j], last[j + 1], cur[j])+1
      }
      last = cur
     }
    return Double (last.last!)        
  }
  
}

// The application also uses an extended version of the Levenstein algorithm.
// The product name, for example, "Soy milk", often consists of several words. 
// And when the application is running, it is necessary to quantify the difference between "Soy milk" and "Milk". 
// Thus, the application divides the compared words into three types:
// 1) Identical words (error between 0 ... 0.01).
// 2) Similar words (error between 0.02... 3.99).
// 3) Different words (the error is more than 4).
// The operation of the method is not instantaneous, but takes some time. 
// For this reason, this method works in a separate thread and does not affect the speed of the application.
func levenstainSecondLevel(str_1: String, str_2: String, limit: Bool) -> Double {
        
  // Empty products return the maximum error
  // Maximum error means that the application no longer treats words as similar
  
        if str_1 == "" || str_2 == "" {
            if !limit {
                return MAXCOUNTWORDERROR_NO_LIMIT // = 50
            } else {
                return MAXCOUNTWORDERROR // = 4
            }
        }
        
  // Words are separated by arrays. The delimiters are spaces between words.
  // It is necessary that the products "Soy milk" and "Milk soy" are considered the same words.
  
        var massiveStr1: [Substring] = []
        var massiveStr2: [Substring] = []
        
        if str_1.split(separator: " ").count < str_2.split(separator: " ").count {
            massiveStr1 = str_1.split(separator: " ")
            massiveStr2 = str_2.split(separator: " ")
        } else {
            massiveStr2 = str_1.split(separator: " ")
            massiveStr1 = str_2.split(separator: " ")
        }
        
        var enableSmallError: Bool
        var dLevenstain = [[Double]]()
        var dLevenstainHelper = [[Double]]()
        
        dLevenstain = Array(repeating: Array(repeating: 0, count: massiveStr2.count), count: massiveStr1.count)
        
        if massiveStr1.count < 1 || massiveStr2.count < 1 {
            if !limit {
                return MAXCOUNTWORDERROR_NO_LIMIT
            } else {
                return MAXCOUNTWORDERROR
            }
        }
        for i in 0...massiveStr1.count - 1 {
            enableSmallError = false
            for j in 0...massiveStr2.count - 1 {
                dLevenstain[i][j] = levenstain(text_1: String(massiveStr1[i]), text_2: String(massiveStr2[j]))
                if !limit {
                    if dLevenstain[i][j] < MAXCOUNTWORDERROR_NO_LIMIT && !enableSmallError {
                        enableSmallError = true
                    }
                } else {
                    if dLevenstain[i][j] < MAXCOUNTWORDERROR && !enableSmallError {
                        enableSmallError = true
                    
                }
            }
            if !enableSmallError {
                if !limit {
                    return MAXCOUNTWORDERROR_NO_LIMIT
                } else {
                    return MAXCOUNTWORDERROR
                }
            }
        }
        
        var countAccessErrorInTheLine: Int
        var currentCountAccessErrorInTheLine: Int
        var currentCountErrorInTheColumn: Double
        var numberLineWithMinimumError: Int
        var numberColumnWithMinimumError: Int
        var differentWord: Double = 0
        var kError: Double = 0
        
        currentCountAccessErrorInTheLine = dLevenstain.count + 2
                    numberLineWithMinimumError = 0
                    for i in 0...dLevenstain.count - 1 {
                        countAccessErrorInTheLine = 0
                        for j in 0...dLevenstain[0].count - 1 {
                            if !limit {
                                if dLevenstain[i][j] < MAXCOUNTWORDERROR_NO_LIMIT {
                                    countAccessErrorInTheLine += 1
                                }
                            } else {
                                if dLevenstain[i][j] < MAXCOUNTWORDERROR {
                                    countAccessErrorInTheLine += 1
                                }
                            }
                            
                        }
                        if countAccessErrorInTheLine < currentCountAccessErrorInTheLine {
                            currentCountAccessErrorInTheLine = countAccessErrorInTheLine
                            numberLineWithMinimumError = i
                        }
                    }
                    
        if !limit {
            currentCountErrorInTheColumn = MAXCOUNTWORDERROR_NO_LIMIT
        } else {
            currentCountErrorInTheColumn = MAXCOUNTWORDERROR
        }
                    
        numberColumnWithMinimumError = 0
                    
        for j in 0...dLevenstain[0].count - 1 {
            if dLevenstain[numberLineWithMinimumError][j] < currentCountErrorInTheColumn {
                currentCountErrorInTheColumn = dLevenstain[numberLineWithMinimumError][j]
                numberColumnWithMinimumError = j
            }
        }
                    
        kError += dLevenstain[numberLineWithMinimumError][numberColumnWithMinimumError]
                    
        let ii: Int = str_1.split(separator: " ").count
        let jj: Int = str_2.split(separator: " ").count
        let kk: Int = max(ii, jj)
        
        var dLevenstainNew = [Double]()
        if !limit {
            dLevenstainNew = Array(repeating: MAXCOUNTWORDERROR_NO_LIMIT, count: kk)
        } else {
            dLevenstainNew = Array(repeating: MAXCOUNTWORDERROR, count: kk)
        }
        
        if ii >= jj {
            for i in 0 ... ii - 1 {
                var min = MAXCOUNTWORDERROR
                if !limit {
                    min = MAXCOUNTWORDERROR_NO_LIMIT
                }
                for j in 0 ... jj - 1 {
                    if dLevenstain[j][i] < min {
                        min = dLevenstain[j][i]
                    }
                }
                dLevenstainNew[i] = min
            }
        } else {
            for j in 0 ... jj - 1 {
                var min = MAXCOUNTWORDERROR
                if !limit {
                    min = MAXCOUNTWORDERROR_NO_LIMIT
                }
                for i in 0 ... ii - 1 {
                    if dLevenstain[i][j] < min {
                        min = dLevenstain[i][j]
                    }
                }
                dLevenstainNew[j] = min
            }
        }
        
// Adding a correction factor that depends on the difference in the number of words being compared
                    
        differentWord = 0
        if kk > 1 {
            var f: [Double] = []
            if kk == 2 {
                f = ERRORWORD_2
            } else if kk == 3 {
                f = ERRORWORD_3
            } else if kk == 4 {
                f = ERRORWORD_4
            } else if kk == 5 {
                f = ERRORWORD_5
            } else if kk == 6 {
                f = ERRORWORD_6
            } else {
                if !limit {
                    return MAXCOUNTWORDERROR_NO_LIMIT
                } else {
                    return MAXCOUNTWORDERROR
                }
            }
            
            for i in 0...max(ii, jj) - 1 {
                if dLevenstainNew[i] > ACCEPTCOUNTWORDERROR{
                    differentWord += f[i]
                }
            }
        }
        
        if !limit {
            if differentWord >= MAXCOUNTWORDERROR_NO_LIMIT {
                return MAXCOUNTWORDERROR_NO_LIMIT
            }
        } else {
            if differentWord >= MAXCOUNTWORDERROR {
                return MAXCOUNTWORDERROR
            }
        }
        if dLevenstain.count - 2 >= 0 && dLevenstain[0].count - 2 >= 0 {
            dLevenstainHelper = Array(repeating: Array(repeating: 0, count: dLevenstain[0].count - 1), count: dLevenstain.count - 1)
            for i in 0...dLevenstain.count - 2 {
                for j in 0...dLevenstain[0].count - 2 {
                    dLevenstainHelper[i][j] = dLevenstain[i][j]
                }
            }
            dLevenstain = dLevenstainHelper
        }

        if str_1 != str_2 {
            return (kError / Double(massiveStr1.count)) + differentWord + ERRORPLACEWORDS
        } else {
            return (kError / Double(massiveStr1.count)) + differentWord
        }
          
        
    }
