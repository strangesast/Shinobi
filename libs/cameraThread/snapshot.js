const fs = require('fs')
const spawn = require('child_process').spawn
var writeToStderr = function(text){
  // fs.appendFileSync(rawMonitorConfig.sdir + 'errors.log',text + '\n','utf8')
}
process.send = process.send || function () {};
process.on('uncaughtException', function (err) {
    writeToStderr('Uncaught Exception occured!');
    writeToStderr(err.stack);
});
// [CTRL] + [C] = exit
process.on('SIGINT', function() {
  if(snapProcess && snapProcess.kill)snapProcess.kill('SIGTERM')
});
if(!process.argv[2] || !process.argv[3]){
    return writeToStderr('Missing FFMPEG Command String or no command operator')
}
var jsonData = JSON.parse(fs.readFileSync(process.argv[3],'utf8'))
// fs.unlink(process.argv[3],()=>{})
const ffmpegAbsolutePath = process.argv[2].trim()
const ffmpegCommandString = jsonData.cmd
const temporaryImageFile = jsonData.temporaryImageFile
const iconImageFile = jsonData.iconImageFile
const useIcon = jsonData.useIcon
const rawMonitorConfig = jsonData.rawMonitorConfig

// var writeToStderr = function(text){
//   process.stderr.write(Buffer.from(text))
// }

var snapProcess = spawn(ffmpegAbsolutePath,ffmpegCommandString,{detached: true})
snapProcess.stderr.on('data',(data)=>{
  writeToStderr(data.toString())
})
snapProcess.stdout.on('data',(data)=>{
  writeToStderr(data.toString())
})
snapProcess.on('close',function(data){
  if(useIcon === true){
    var fileCopy = fs.createReadStream(temporaryImageFile).pipe(fs.createWriteStream(iconImageFile))
    fileCopy.on('close',function(){
        process.exit();
    })
  }else{
    process.exit();
  }
});
