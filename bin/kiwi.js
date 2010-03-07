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
var kiwiServer = http.createClient(process.env.SERVER_PORT?process.env.SERVER_PORT : "80",
                                   SERVER_ADDR);
var inVerboseMode= false;

function log (type, message ) {
    if( inVerboseMode) sys.puts(fixedCharFormat(type,10) + " : "+ message);
} 
function abort(message, callback) {
    sys.puts("Error: "+ message );
    if( callback ) callback();
}

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

/* Switch "current" environment to [env].
 * 
 * [env]
 *
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
 * Given an argument string, split it into its constituent parts
 */
function splitArgs(argString) {
    // TODO: this should be smarter to allow for whitespace escaping... 
   return argString.split(/\s/);
}   


/** 
 * Parse either command line arguments or REPL commands
 * [args]
 * [inRepl]
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
            case "search":
                search(args[argIndex], callback);
                break;
            case "env":
            case "envs": 
                  list_environments(callback);
                  break;                
            case "switch":
                 switch_environment(args[argIndex], callback);
                 break;
            case "repl":
              if(!inRepl) repl();
              else callback();
              break;
            case "whoami":
                output_username(callback);
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
* Search remote seeds with the given [pattern].
* 
* [pattern]
*/
function search(pattern, callback) { 
    var url= "/search";
    if( pattern ) url+= "?name="+pattern;
    var request = kiwiServer.request("GET", url  , {"host": SERVER_ADDR});
    var result= "";
    request.addListener('response', function (response) {
      response.setBodyEncoding("utf8");
      response.addListener("data", function (chunk) {
        result += chunk;
      });
      response.addListener("end", function (chunk) {
        sys.puts(result); 
        callback();
      });
    });
    request.close();
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