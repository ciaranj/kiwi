var sys= require('sys');
var http= require('http');

var VERSION="0.0.1";
var ORIGIN="git://github.com/ciaranj/kiwi.git";
var KIWI_DEST= "~/.kiwi";
var AUTH_DEST= KIWI_DEST+"/.auth";
var SEED_DEST= KIWI_DEST+"/current/seeds";
var SERVER_ADDR= process.env.SERVER_ADDR?process.env.SERVER_ADDR : "173.203.199.182"; 

var kiwiServer = http.createClient(process.env.SERVER_PORT?process.env.SERVER_PORT : "80",
                                   SERVER_ADDR);
var inVerboseMode= false;

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
    "      update self                  Updates kiwi to the latest release\n" +
    "      whoami                       Output currently registered user name\n" +
    "      list                         Lists installed seeds and their associated versions\n" +
    "      envs                         List environments available to kiwi\n";
    if(inRepl) {
        commands += "      help                         Help information\n";    
        commands += "      quit                         Exit the kiwi interactive console (REPL)\n";    
    }
    else commands += "\n";
                                     
    var installationOptions= "    Install:\n" +
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
    if( inRepl ) sys.puts(commands);
    else sys.puts(shellUsage + commands + installationOptions);
}

function setup() {
    
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
              if( args[argIndex] == 'self' ) updateSelf(callback);
              else update(callback);
              break;
            case "search":
                search(null, callback);
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
                if(!inRepl) sys.puts("Error: invalid option `"+ command + "'. Use --help for more information");
                else callback();
        }
    }
}

function update(callback) { sys.puts('update');callback();}
function updateSelf(callback) { sys.puts('update self');callback();} 
function list(callback) { sys.puts('list');callback();}  
   
function run() {
    if( process.argv.length == 2 && process.argv[0] == 'node' ) {
        // Not quite sure about the node execution cycle is 'node foo.js' the only path or do hash-bangs work?
        repl();
    } else {
        parseArguments(process.argv);
    }
}   

/*
* Search remote seeds with the given [pattern].
* 
* [pattern]
*/
function search(pattern, callback) { 
    sys.puts("search"); 
    callback();
    /*
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
      });
    });
    request.close();     */
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

run();