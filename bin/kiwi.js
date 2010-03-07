var sys= require('sys'),
    http= require('http'),
    fs= require('fs'),
    path= require('path');

var VERSION="0.0.1";
var ORIGIN="git://github.com/ciaranj/kiwi.git";
var KIWI_DEST= "~/.kiwi";
var AUTH_DEST= KIWI_DEST+"/.auth";
var SEED_DEST= KIWI_DEST+"/current/seeds";
var SERVER_ADDR= process.env.SERVER_ADDR?process.env.SERVER_ADDR : "173.203.199.182";
var SERVER_PORT= process.env.SERVER_PORT?process.env.SERVER_PORT : "80";
var kiwiServer = http.createClient(SERVER_PORT,SERVER_ADDR);
var inVerboseMode= false;

function log (type, message ) {
    if( inVerboseMode) sys.puts(fixedCharFormat(type,10) + " : "+ message);
} 
function abort(message, callback) {
    sys.puts("Error: "+ message );
    if( callback ) callback(new Error(message));
}
 
// Base64 Encoder taken from: http://www.webtoolkit.info/javascript-base64.html
var _keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
function encodeInBase64 (input) {
	var output = "";
	var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
	var i = 0;

	while (i < input.length) {

		chr1 = input.charCodeAt(i++);
		chr2 = input.charCodeAt(i++);
		chr3 = input.charCodeAt(i++);

		enc1 = chr1 >> 2;
		enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
		enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
		enc4 = chr3 & 63;

		if (isNaN(chr2)) {
			enc3 = enc4 = 64;
		} else if (isNaN(chr3)) {
			enc4 = 64;
		}

		output = output +
		_keyStr.charAt(enc1) + _keyStr.charAt(enc2) +
		_keyStr.charAt(enc3) + _keyStr.charAt(enc4);

	}

	return output;
};


function fixedCharFormat(str, length) {
    if( str.length == length ) return str;
    if( str.length > length ) return str; // Substring ?
    var padding= length -str.length;
    for(var i= 0;i<padding;i++) {
        str = (" "+str);
    }
    return str;
}

/*
* Executes the callback with no arguments if seeds are present, otherwise the first argument
* to the callback will be an error.s
*/
function require_seeds(callback) { 
    fs.readdir(expand_path(SEED_DEST), function(err, files){
        if( err || files.length == 0 ) callback(new Error("no seeds are installed."));
        else callback();
    });
}

/*
* Require presence of seed info <file> or abort.
* 
* <file>
*/
function require_seed_info_file(file, callback) {
    path.exists( file, function (exists) { 
        if( exists ) callback();
        else abort("seed.yml file required.", callback);
    });
}

/*
* Require presence of seed [name] or abort.
* 
* <name>
*/
function require_seed_name( name, callback ) {
  if( name === undefined ) abort("seed name required."); 
  return name !== undefined;
}

/*
* Require presence of seed [version] or abort.
* 
* <version>
*/
function require_seed_version( version, callback ) {
    if( version === undefined ) abort("seed version required.");
    return version !== undefined;
}

/*
 * Print the usage instructions
 * [inRepl] - If true then the REPL usage instructions will be displayed rather than the shell instructions.
 */
function printUsage( inRepl ) { 
    var shellUsage= "    Usage:\n" +
    "\n" +
    "      kiwi [options] [command] [arguments]\n" +
    "\n"+
    "    Options:\n" +
    "\n" +
    "      -v, --verbose     Verbose output\n" +
    "      -V, --version     Current version triplet\n" +
    "      -S, --seeds       Output seed directory\n" +
    "      -h, --help        Help information\n" +
    "\n"; 

    var commands= "    Commands:\n\n";
    if( !inRepl ) commands+= "      <void>                       Starts a kiwi interactive console (REPL)\n";
    commands+=
    "      install <name> [version]     Installs a seed <name> with optional [version]\n" +
    "      uninstall <name> [version]   Uninstalls all versions of seed <name> or the given [version]\n" +
    "      switch <env>                 Switch to kiwi to use the given seed <env>\n" +
    "      search [pattern]             Search remotely available seeds with optional [pattern]\n" +
    "      build <version>              Build <version>.seed with the contents of the current directory\n" +
    "      publish <name> <version>     Push seed <name> and <version> to the kiwi server\n" +
    "      release <name> <version>     Build and publish seed <name> and <version>\n" +
    "      register <name> <password>   Attempt to register the given <user> name and <password>\n" +
    "      update                       Install the latest release of every seed installed\n" +
    "      whoami                       Output currently registered user name\n" +
    "      list                         Lists installed seeds and their associated versions\n" +
    "      envs                         List environments available to kiwi\n";
    if(inRepl) {
        commands += "      help                         Help information\n";    
        commands += "      quit                         Exit the kiwi interactive console (REPL)\n";    
    }
                                     
    var installationOptions= "\n    Install:\n" +
    "\n" +
    "      Installing the latest version of a seed:\n" +
    "\n" +
    "        $ kiwi install sass\n" +
    "\n" +
    "      Installing a specific version:\n" +
    "\n" +
    "        $ kiwi install sass \">~ major.minor.patch\"\n" +
    "\n" +
    "      The following operators are supported for matching versions:\n" +
    "\n" +
    "        n/a               Equal to\n" +
    "        =                 Equal to\n" +
    "        >                 Greater than\n" +
    "        >=                Greater than or equal to\n" +
    "        >~                Greater than or equal to with compatibility (major must match)\n";
    if( inRepl ) sys.puts(commands + installationOptions);
    else sys.puts(shellUsage + commands + installationOptions);
}

function expand_path(path) {
     return path.replace("~", process.env.HOME);
}

function create_directory(path, callback) {
    var path= expand_path(path); // First of all expand out the '~' home directory.
    var pathSegments= path.split("/");   
    if( pathSegments[0] == '' ) {
        pathSegments= pathSegments.slice(1);
    }
    for(var i=0; i<=pathSegments.length; i++) {
        var pathSegment= "/"+pathSegments.slice(0,i).join("/");
        try {
            fs.statSync(pathSegment); 
        }
        catch(e) {
            fs.mkdirSync(pathSegment, 0777);
        }
    } 
    callback();
}   

/* Switch "current" environment to <env>.
 * <env>
 */
function switch_environment(env, callback) {
    if(!env)  abort( "environment name required.", callback);
    else {
      var dir= expand_path(KIWI_DEST+ "/"+ env);
   
      path.exists( dir, function (exists) {
          var nextStep= function() {
              log("switch", "current -> "+ env);    
              path.exists( expand_path(KIWI_DEST+"/current"), function(currentExists){
                 var nextNextStep= function() {
                     fs.symlink( dir, expand_path(KIWI_DEST + "/current"), callback );
                 };
                 
                 if( currentExists ) {
                     fs.unlink(expand_path(KIWI_DEST+"/current"), function(error) {
                         //TODO: propagate errors properly.
                         if(error) abort( error ); 
                         nextNextStep();
                     }); 
                 }  else  nextNextStep();
              });
          };

          if( exists ) nextStep();
          else create_directory( dir, nextStep );
      });
  }  
}


function setup(callback) {
    path.exists(expand_path(KIWI_DEST+"/default"), function (exists) {
        var nextStep= function() {
            path.exists(expand_path(SEED_DEST), function(exists){
                if( exists ) callback();
                else create_directory(SEED_DEST, callback);
            });
        };
        if( exists ) nextStep();
        else switch_environment( 'default',  nextStep );
    });
}

/*
* Create SEED_DEST/<name>/<version>.
* 
* <name> <version>
*/
function setup_seed(name, version, callback) {
  var dir= path.join(SEED_DEST, name, version);
  log("create",  dir);
  create_directory(dir, callback);
}

/*
 * Given an argument string, split it into its constituent parts
 * To pass arguments that contain whitespace, surround the argument
 * with double-quotes e.g. "foo bar"
 */
function splitArgs(argString) {
    var regex= /"[^"]*?"|[^\s]+/g; 
    var results= [];
    do {
        var result=  regex.exec(argString);
        if(result)  {
            result= result[0];
            trim(result);
            if( result[0] == "\"") result= result.substr(1);
            if( result[result.length-1] == "\"") result= result.substr(0, result.length-1);
            
            results[results.length]= result;
        }
        
    } while( result != null );
   return results;
}   


/** 
 * Parse either command line arguments or REPL commands
 * <args>
 * [callback]
 */
function parseArguments(args, callback) {  
    var inRepl = (callback != undefined);
    if( !callback) callback=  function() {};

    var argIndex= inRepl?0:2,
        keepGoing= true, 
        arg="";
    if( typeof(args) == 'string' ) args= splitArgs(args);
    while(keepGoing && argIndex < args.length) {
        var command= args[argIndex++];   
        keepGoing=false;
        switch(command) {
            case "help":
            case "-h":
            case "--help":
                printUsage(inRepl);
                callback();
                break;
            case "-S":
            case "--seeds":
                if(!inRepl) sys.puts(SEED_DEST);
                break;
            case "-V":
            case "--version":
                if(!inRepl) sys.puts(VERSION);
                break;
            case "-v":
            case "--verbose":
                if(!inRepl) inVerboseMode= true;
                keepGoing= true;
                break;
            case "update":
                update_all(callback);
                break;
            case "install":
            case "add":
            case "get": 
                install( args[argIndex++], args[argIndex++], args[argIndex], callback );
                break;
            case "switch":
                 switch_environment(args[argIndex], callback);
                 break; 
            case "register":
                register_user( args[argIndex++], args[argIndex], callback);
                break;
            case "search":
                search(args[argIndex], callback);
                break;
            case "env":
            case "envs": 
                list_environments(callback);
                break;                
            case "whoami":
                output_username(callback);
                break;
            case "repl":
                if(!inRepl) repl();
                else callback();
                break;
            case "list":
            case "ls":
                list(callback);
                break;
            default:
                if(!inRepl) abort("invalid option `"+ command + "'. Use --help for more information");
                else callback();
        }
    }
}

/*
*
* Install a seed <name> with [version]. (Version may be a 'bounded version')
*
* When a <file> is passed, it should be a flat-list
* of seeds to install, formatted as:
*   <name> [op] <version>\n
*   <name> [op] <version>\n
*   ...
*
* Otherwise:
* 
*   - Fetches latest version when [version] absent
*   - Downloads seed tarball
*   - Unpacks the tarball
* 
* <nameOrFile> [<operator> <version] | [version]]
*
*/
function install(nameOrFile, versionOrOperator, version, callback) {
    if( version ) version= versionOrOperator + " " + version;
    else version= versionOrOperator;
    
    if( !require_seed_name(nameOrFile) ) callback();
    else {
        log( "install", nameOrFile + " " + (version?version:"") );
        path.exists(nameOrFile, function(exists) {
            if( exists ) {
                log( "install", "from file" );
                splitFilesIntoLines(nameOrFile, function(err,lines){
                    //TODO: propagate errors properly..
                  var lineIndex=0;
                  var installLine= function() {
                      var lineArgs= splitArgs(lines[lineIndex]);
                      lineArgs.unshift("install");
                      parseArguments( lineArgs, function() {
                       if( ++lineIndex < lines.length ) installLine();
                       else callback();
                      });
                  };
                  installLine();
                });                
            } else {
                var url= "/"+nameOrFile+"/resolve";
                if( version ) url+= "?version="+escape(version);
                get_from_server( url, function(error, resolvedVersion) {
                    if( resolvedVersion == "seed version does not exist."  ||
                        resolvedVersion == "seed does not exist.") {
                        abort(resolvedVersion, callback);
                    } 
                    else {
                        log("resolve", "version "+ resolvedVersion);  
                        path.exists(path.join(expand_path(SEED_DEST),nameOrFile, resolvedVersion) , function(seedVersionExists){
                            if( seedVersionExists ) {
                                log("install", "already installed");
                                callback();
                            } else {
                                download(nameOrFile, resolvedVersion, function(error, seedPath) {
                                    unpack(seedPath, function(err) {
                                        if( err ) callback(err); 
                                        else {
                                            build(path.dirname(seedPath), function() { 
                                                install_dependencies(path.join(path.dirname(seedPath), "seed.yml"), callback);
                                            });
                                        }
                                    });
                                });
                            }
                        });
                    }
                });
            }
        });
    } 
}

function update_all(callback) { sys.puts('update_all');callback();}

/*
* List installed seeds and their associated versions.
*/ 
function list(callback) { 
    require_seeds(function(error) { 
        if( error ) abort(error.message, callback);
        else {
            fs.readdir(expand_path(SEED_DEST), function(err, files){
                if( !err ) {
                   var file, joinedPath;
                   for(var i=0;i<files.length;i++) { 
                       file= files[i];
                       joinedPath= path.join(expand_path(SEED_DEST),file);
                       sys.print( fixedCharFormat(file,15) + " : " );
                       var versions= fs.readdirSync(joinedPath);
                       for(var j=0;j<versions.length;j++) { 
                           sys.print( versions[j] +" " );
                       }
                       sys.puts("");
                   }
                   callback();
                }
                else abort(err, callback);
            });
        }
    });
}  

/*
 * List environments, prefixing '*' to the current env.
 */
function list_environments(callback) {
    var expanded_kiwi_dest= expand_path(KIWI_DEST);
    fs.readlink(path.join(expanded_kiwi_dest,"current"), function(error, current) {
        fs.readdir(expand_path(expanded_kiwi_dest), function(err, files){
            for(var i=0;i<files.length;i++) {
                if( files[i] != "current" && files[i] != ".auth") {
                    if( path.join(expanded_kiwi_dest, files[i]) == current )  sys.print("* ");
                    else sys.print("  ");
                    sys.puts(files[i]);
                }
            }
            callback();
        });
    });
}

/*
 * Output username.
 */
function output_username(callback) {
    var expanded_auth_dest= expand_path( AUTH_DEST );
    path.exists(expanded_auth_dest, function(exists) {
        if( !exists ) {
            sys.puts( "Credentials cannot be found, please register first." );
            sys.puts( "  If you have previously registered simply run:" );
            sys.puts( "  $ echo user:pass > " + expand_path( AUTH_DEST ) );
            callback();
        }
        else {
            fs.readFile(expanded_auth_dest, function (err, data) {
                //Errors?
              sys.puts(data.substr(0,data.indexOf(":")));
              callback();
            });            
        }
        
    });
    
}
 
/*
 * Registers a username and password (using basic auth bleurgh!)
 */
function register_user( name, pass, callback ) { 
    if( name === undefined ) { abort("user name required.", callback); return; }
    if( pass === undefined ) { abort("abort password required.", callback); return; }
    var request = kiwiServer.request("POST", "/user" , {"host": SERVER_ADDR,
                                                        "Authorization": "Basic "+ encodeInBase64(name+":"+pass),
                                                        "Content-Length": 0});
    var result= "";
    request.addListener('response', function (response) {
      response.setBodyEncoding("utf8");
      response.addListener("data", function (chunk) {
        result += chunk;
      });
      response.addListener("end", function (chunk) {
        if( trim(result) == "registration failed." ) {
            abort("Registration failed.", callback);
        } else {
            log("create", expand_path(AUTH_DEST) );
            fs.open(expand_path(AUTH_DEST), "w", 0600, function(err, fd) {
                fs.write(fd, name +":"+ pass, 0, "utf-8", callback);
            });   
        }
      });
    });
    request.close();
}

/*
 * Retrieves some data from the Kiwi server and returns
 * it to the callback function.
 * TODO: error handling.
 */ 
function get_from_server(url, callback) {
    var request = kiwiServer.request("GET", url  , {"host": SERVER_ADDR});
    var result= "";
    request.addListener('response', function (response) {
      response.setBodyEncoding("utf8");
      response.addListener("data", function (chunk) {
        result += chunk;
      });
      response.addListener("end", function (chunk) {
        callback(null, result, response);
      });
    });
    request.close();
}

/*
 * Tediously enough this function does a recursive rmdir, deleting
 * all the contents of a folder (and all its child folders).
 */
function recursiveRmDir(dir, callback) {
    fs.readdir(dir, function(error, results) {
        if( results && results.length == 0 ) {
            fs.rmdir( dir, callback );
        } 
        else {
            var filesToRemove= results.length;
            var decrementFiles= function() {
                filesToRemove--;
                if(filesToRemove<=0) {
                    fs.rmdir( dir, callback );
                }
            };
            for(var i=0;i<results.length;i++) {
                var fullPath= path.join(dir, results[i]);
                fs.stat(fullPath, function(err, stats) {
                    if( stats.isDirectory() ) { 
                        recursiveRmDir(fullPath, decrementFiles);
                    } 
                    else {
                        fs.unlink(fullPath, decrementFiles );
                    }
                });
            }
            
        }
    });
}

/*
 * Given a file, will return a set of (line ending removed/normalised) lines
 * to a given callback, or an error as the first argument
 */
function splitFilesIntoLines( file, callback ) {
    fs.readFile( file, function (err, data) {
        if( err ) callback(err);
        else {
            callback(null, data.replace("\r","").split("\n")) ;
        }
    });
}

/* Unpack <seed> using tar. 
*  TODO: REMOVE THE DEPENDENCY ON TAR somehow?!?! anyone
* <seed>
*/
function unpack( seedPath, callback ) {
  var dir= path.dirname( seedPath ); 
  log( "unpack", seedPath );
  sys.exec("tar -xzvf "+seedPath+ " -C "+ dir +" 2> /dev/null", function (err, stdout, stderr) {
    var nextStep= function(err) {
        log( "remove", seedPath );
        fs.unlink(seedPath, function() { callback(err); });
    };
    if (err)  {
        log( "remove", dir );
        abort( "failed to unpack. Seed is invalid or corrupt.");
        recursiveRmDir(dir,function(error) {
            nextStep(err);
        });
    }
    else {
        nextStep();
    }
  });
}

/*
* Search remote seeds with the given [pattern].
* 
* [pattern]
*/
function search(pattern, callback) { 
    var url= "/search";
    if( pattern ) url+= "?name="+pattern; 
    get_from_server( url, function(error, result) {
        sys.puts(result); 
        callback();
    });
} 

/*
* Download seed <name> with <version> to $SEED_DEST/<name>/<version>/<name>.seed
* 
* Passes the path to the seed archive back to the callback
* 
* <name> <version>
*
*/
function download( name, version, callback) {
  setup_seed(name, version, function() {
      log( "fetch", version+".seed" );
      var seedPath= path.join(expand_path(SEED_DEST), name, version, name+".seed");
      fs.open(seedPath, "w", 0600, function(error, fd) {
          var request = kiwiServer.request("GET", "/seeds/"+name+"/"+version+".seed"  , {"host": SERVER_ADDR});
          
          // TODO: should be able to sort out streaming to disk (not sure if async writes get queued linearly or not...)
          request.addListener('response', function (response) {
            response.setBodyEncoding("binary");
            response.addListener("data", function (chunk) { 
                if(inVerboseMode) sys.print(".");
                fs.writeSync(fd, chunk, null, "binary");
            });
            response.addListener("end", function (chunk) {
                sys.puts("");
                callback( null, seedPath );
            });
          });
          if(inVerboseMode) sys.print("Downloading...");
          request.close();          
      });
  })
}

/*
* Build seed in the given <dir>.
* 
* <dir>
*/
function build(dir, callback) {
    var info = path.join(dir, "seed.yml")
    require_seed_info_file(info, function(error){
        if(error) callback(error);
        else {
            splitFilesIntoLines(info, function(err, lines){
                var command= undefined;
                for(var i=0;i<lines.length;i++) {
                    var matches= /^\s+build:\s(.+)$/.exec(lines[i]);
                    if( matches ){
                         sys.puts( matches[1] ); 
                         command= matches[1];
                         break;
                     }
                }
                if( command ) {
                    log("cd", dir);
                    log("build", command);
                    sys.exec("cd "+ dir+"; "+ command, function (err, stdout, stderr) {
                      if (err) callback(err);
                      else {
                          if(inVerboseMode) sys.puts(stdout);
                          callback();
                      }
                    });
                } else callback();
            });
        }
    });
}

/*
* Install dependencies defined in the given seed info <file>.
* 
* <file>
*/
function install_dependencies(seedInfoFile, callback) {
    require_seed_info_file(seedInfoFile, function(error) {
        if( error ) callback(error);
        else {
            log("check", "dependencies");  
            sys.puts("STILL NEEDS IMPLEMENTING");
            //TODO: TJ's server doesn't currently have any seeds with deps to do this.. and I'm lazy.
            splitFilesIntoLines(seedInfoFile, function(err, lines){
//                sys.puts(lines);
                callback();
            });
        }
    });    
/*  require_seed_info_file $1
  log check dependencies
  deps=0
  cat $1 | while read line; do
    [[ $line =~ dependencies: ]] && deps=1
    [[ $deps -ne 0 && $line =~ ^\s*- ]] && deps=2
    [[ $deps -eq 2 && $line =~ ^\s*.+: ]] && deps=0
    [[ $deps -eq 2 ]] && kiwi $FLAGS install $(normalize_version $line)
  done */
}
 
function trim(str) {
    return str.replace(/^\s*/, '').replace(/\s*$/, ''); 
}                                                

function prompt() {
    sys.print ('kiwi> '); 
} 

/*
* Start kiwi REPL.
*/
function repl() {
    process.stdio.open();
    prompt(); 
    process.stdio.addListener("data", function (data) {
        if( data ) data= trim(data);  
        
        if( data && data.match(/^quit$/i) )  {
            process.stdio.close();
            sys.puts('Bye Bye');
        } else {
            parseArguments(data, function() {
                prompt(); 
            });
        } 
    });
}

function run() { 
    setup(function() {
        if( process.argv.length == 2 && process.argv[0] == 'node' ) {
            // Not quite sure about the node execution cycle is 'node foo.js' the only path or do hash-bangs work?
            repl();
        } else {
            parseArguments(process.argv);
        }
    });
}

run();


