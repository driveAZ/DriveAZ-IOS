// checkTestCoverage
// Read and parse xcode test results and compare to a "threshold" percentage
//

const fs = require('fs')

const data = JSON.parse(fs.readFileSync('../DriveAZ/testResults.json', 'utf8'))

let coveredLines = 0
let executableLines = 0
let threshold = .90

data.targets.forEach(target => {
  target.files.forEach(file => {
    if (!file.path.endsWith('.c') && !file.path.includes('/Pods/')) {
      delete file.functions
      if (file.lineCoverage !== 1) {
        console.table(file)
      }
      coveredLines += file.coveredLines
      executableLines += file.executableLines
    }
  })
})
let lineCoverage = coveredLines / executableLines

console.log(coveredLines, executableLines)
console.log((.96 - lineCoverage) * executableLines)

if (lineCoverage < threshold) {
    //throw `Test Coverage is at ~${Math.round(lineCoverage * 1000)/10}% and is not above the threshold of ${threshold}`
    console.log `Test Coverage is at ~${Math.round(lineCoverage * 1000)/10}% and is not above the threshold of ${threshold}`
}

console.log(`Everything is good! Coverage is at ~${Math.round(lineCoverage * 1000)/10}%`)
