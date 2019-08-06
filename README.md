# DebuggableASTInterpreter
An AST interpreter that accepts stepping operations

# Installation
## Install only the interpreter
```Smalltalk
Metacello new
    baseline: 'DebuggableASTInterpreter';
    repository: 'github://carolahp/DebuggableASTInterpreter';
    load.
```

## Install the debugger

```Smalltalk
Metacello new
    baseline: 'DebuggableASTInterpreter';
    repository: 'github://carolahp/DebuggableASTInterpreter';
    load: #Debugger.
```

Execute the following code in a playground with a `doIt` to test the debugger.

```Smalltalk
(DASTSpecDebugger on: (DASTSession debug: 'MyObject new doStuff')) openWithFullView 
```


## Install the overlays experiments for debugging in isolation (Experimental!)
That is not yet synchronized with the master branch.
```Smalltalk
Metacello new
    baseline: 'DebuggableASTInterpreter';
    repository: 'github://carolahp/DebuggableASTInterpreter';
    load: #Overlay.
```

# Example
In a playground, instanciate an interpreter and initialize it with the program you want it to interpret (here: `Point x: 1 y: 2`)
```Smalltalk
interpreter := DASTInterpreter new.
interpreter initializeWithProgram: (RBParser parseExpression: 'Point x: 1 y: 2').
```


You can see the stack of AST nodes the current context still has to interpret by inspecting: `interpreter currentContext nodes`. The nodes will be interpreted from last to first.
*Node stack:*  
![Node stack](./Pictures/DASTExample1.png)


You can see the value stack of the current context (where the interpreter pushes the values of the AST nodes it interprets) by inspecting: `interpreter currentContext stack`. It is empty at the moment because nothing has been evaluated yet.


Evaluate `interpreter stepInto` 3 times to evaluate the receiver and arguments of the #x:y: message being interpreted.  
*New node stack:*  
![Node stack](./Pictures/DASTExample2.png)  
*New value stack:*  
![Value stack](./Pictures/DASTExample3.png)  


Finally, the message send itself is ready to be interpreted. If you evaluate `interpreter stepOver`, the interpreter will pop the receiver and arguments from the value stack, evaluate the message send completely, and push its value on the value stack.  
*New node stack:*  
![Node stack](./Pictures/DASTExample4.png)  
*New value stack:*  
![Value stack](./Pictures/DASTExample5.png)  

As you can see, the value of the message send is the point it created: `(1@2)`