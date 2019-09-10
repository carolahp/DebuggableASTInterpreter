"
I can interpret a program represented as an AST tree
"
Class {
	#name : #DASTInterpreter,
	#superclass : #Object,
	#instVars : [
		'currentContext',
		'exception',
		'programCounter'
	],
	#category : #'DebuggableASTInterpreter-Core'
}

{ #category : #accessing }
DASTInterpreter >> context [
	self shouldBeImplemented.
]

{ #category : #accessors }
DASTInterpreter >> currentContext [
	^ currentContext.
]

{ #category : #accessors }
DASTInterpreter >> currentNode [
	^ currentContext nodes top
]

{ #category : #evaluation }
DASTInterpreter >> decreasePC [
	programCounter := self programCounter - 1
]

{ #category : #evaluation }
DASTInterpreter >> evaluate [
	|node|
		
	[ currentContext canExecute ] whileTrue: [  
		"node:=currentContext nodes pop. 
		self visit: node ."
		node := currentContext nodes top.
		self stepInto.
		 ].
	^ self stackTop
]

{ #category : #'gt-extension' }
DASTInterpreter >> gtInspectorContextsIn: composite [
	<gtInspectorPresentationOrder: 1>
	self currentContext ifNil: [ ^ composite ].
	^composite fastList
		title: 'Evaluation Stack';
		display: [ {self currentContext} asOrderedCollection , self currentContext senders ]
]

{ #category : #evaluation }
DASTInterpreter >> increasePC [
	programCounter := self programCounter + 1
]

{ #category : #initialization }
DASTInterpreter >> initializeWithProgram: aRBNode [
	| visitor nodes rootContext |
	programCounter := 0.
	visitor := DASTPostOrderTreeVisitor new.
	
	(aRBNode methodNode body addReturn; yourself) acceptVisitor: visitor.
	nodes := visitor stack.
	rootContext := DASTContextRootSmalltalk new. 
	"ugly method necessary because we are putting the root expression of the AST inside a return and sending it the message value"
	self flag: 'update next call'.
	" Set the first method (noMethod) context evaluation. The receiver is nil "
	currentContext := DASTMethodContext new
		parent: rootContext;
		methodOrBlock: (DASTMethod new initializeWith: nodes last methodNode);
		nodes: nodes;
		sender: rootContext;
		yourself.
	
]

{ #category : #testing }
DASTInterpreter >> isTerminated [
	self flag: 'ToDo: is this method necessary?'.
	^ self currentContext nodes isEmpty and: [self currentContext parent isRoot].
]

{ #category : #testing }
DASTInterpreter >> primitiveResultIsError: anObject [
	^ (anObject isKindOf: Array ) and: [(anObject at: 1 ifAbsent: nil) = Context primitiveFailToken first ]
]

{ #category : #accessing }
DASTInterpreter >> programCounter [
	^ programCounter ifNil:[programCounter := 0]
]

{ #category : #visiting }
DASTInterpreter >> readInstanceVariableNamed: name [
	^ (self currentContext findInstanceVariable: name) value
]

{ #category : #accessing }
DASTInterpreter >> receiver [
	^self currentContext receiver
]

{ #category : #private }
DASTInterpreter >> solvePrimitive: anInteger receiver: anObject arguments: anArray [
	| primitiveResult |
		
	"primitives applied to blocks:"
	(anObject isKindOf: DASTClosure) ifTrue: [ 
		anInteger = 266 ifTrue: [ 
			^self stackPush: anObject argumentCount. 
		 ].
		anInteger = 202 ifTrue: [ 
			primitiveResult := anObject tryPrimitive: anInteger withArgs: anArray asArray.
			^ self stackPush: primitiveResult
		].
		DASTPrimitiveFailed signalWithPrimitive: anInteger receiver: anObject 
	].
	 	
	"apply primitive to object"
	primitiveResult := anObject tryPrimitive: anInteger withArgs: anArray asArray.
	(self primitiveResultIsError: primitiveResult)
		ifTrue: [DASTPrimitiveFailed signalWithPrimitive: anInteger receiver: anObject ].
	self stackPush: primitiveResult

]

{ #category : #stack }
DASTInterpreter >> stackPop [
	^ currentContext stack pop
]

{ #category : #stack }
DASTInterpreter >> stackPop: anInteger [
	| pops |
	pops := Array new: anInteger.
	(1 to: anInteger) do: [:i |
		pops at: i put: self stackPop ].
	^ pops
]

{ #category : #stack }
DASTInterpreter >> stackPush: anObject [ 
	currentContext stack push: anObject
]

{ #category : #stack }
DASTInterpreter >> stackTop [
	^ currentContext stack
		ifNotNil: [ :s | s ifEmpty: [ nil ]
								 ifNotEmpty: [s top] ] 
		ifNil: [ nil ]
]

{ #category : #evaluation }
DASTInterpreter >> stepInto [
	| node |
	currentContext canExecute
		ifFalse: [ DASTEvaluationTerminated signal ].
	self visit: (node := currentContext nodes pop).
	self increasePC.
	currentContext executedNodes push: node.
	^ self currentContext
]

{ #category : #evaluation }
DASTInterpreter >> stepOver [
	| initialContext |
	initialContext := currentContext.
	self stepInto.
	[ currentContext ~= initialContext
		"and: [ currentContext ~= initialContext sender ]" ]
		whileTrue: [ self stepInto ].
	^ self currentContext
]

{ #category : #visiting }
DASTInterpreter >> visit: aRBNode [

	aRBNode acceptVisitor: self
]

{ #category : #visiting }
DASTInterpreter >> visitArgumentNode: aRBArgumentNode [ 

	self stackPush: (currentContext findVariable: aRBArgumentNode name)
]

{ #category : #visiting }
DASTInterpreter >> visitArrayNode: aRBArrayNode [ 
	| literals size |
	
	size := aRBArrayNode statements size.
	literals := self stackPop: size.
	self stackPush: literals reverse
]

{ #category : #visiting }
DASTInterpreter >> visitAssignmentNode: aRBAssignmentNode [ 
	| name value |
	name := aRBAssignmentNode variable name.
	value := self stackTop.
	
	"Temporary variables assignment"
	(self currentContext lookupContextDefiningLocalVariable: name)
		ifNotNil: [ :definingContext | definingContext at: name put: value. ^ self ].
	
	"Instance variables assignment"
	(self currentContext receiver class allInstVarNames includes: name)
		ifTrue: [ self write: value toInstVarNamed: name. ^ self].

	"ToDo: fix this step since it's updating the class in the system and not in the environment"
	(self currentContext receiver class classPool includesKey: name)
		ifTrue: [ self currentContext receiver class classPool at: name put: value . ^ self].
		
	Error signal: 'Assignment operation failed for variable "' , name , '" with value "', value asString, '"'
]

{ #category : #visiting }
DASTInterpreter >> visitBlockNode: aRBBlockNode [ 
	
	self stackPush: (DASTBlock new initializeWith: aRBBlockNode; outerContext: currentContext)
]

{ #category : #visiting }
DASTInterpreter >> visitCascadeNode: aRBCascadeNode [ 
	self flag: 'I do nothing'.
]

{ #category : #visiting }
DASTInterpreter >> visitGlobalNode: aRBGlobalNode [ 
	self stackPush: (currentContext findVariable: aRBGlobalNode name)
	
]

{ #category : #visiting }
DASTInterpreter >> visitInstanceVariableNode: aRBInstanceVariableNode [
	self
		stackPush: (self readInstanceVariableNamed: aRBInstanceVariableNode name)
]

{ #category : #visiting }
DASTInterpreter >> visitLiteralArrayNode: aRBLiteralArrayNode [ 
	
	| literals size |
	size := aRBLiteralArrayNode contents size.
	literals := self stackPop: size.
	self stackPush: literals
]

{ #category : #visiting }
DASTInterpreter >> visitLiteralNode: aRBLiteralValueNode [ 

	self stackPush: aRBLiteralValueNode value
]

{ #category : #visiting }
DASTInterpreter >> visitLiteralValueNode: aRBLiteralValueNode [ 

	self visitLiteralNode: aRBLiteralValueNode 
]

{ #category : #visiting }
DASTInterpreter >> visitMessageNode: aRBMessageNode [ 
	| arguments receiver method newContext |
	" Resolve Arguments "
	arguments := (self stackPop: aRBMessageNode numArgs) reverse.	
	(aRBMessageNode isCascaded and: [aRBMessageNode isFirstCascaded not]) ifTrue: [ self stackPop ].
	receiver := self stackPop.
	
	" Current context initialization (implicit lookup)"
	newContext := 
		DASTContext
			newWithSender: self currentContext 
			receiver: receiver 
			messageNode: aRBMessageNode.
	
	" Lookup"
	method := newContext methodOrBlock.
	
	" Apply - invoke method "
	(aRBMessageNode isCascaded and: [aRBMessageNode parent messages last ~= aRBMessageNode]) ifTrue: [ self stackPush: receiver ]. 
	(method isPrimitive and: [method isMessageValue not and: [method isOnDo not]] )  
	ifTrue: [ 
		[ ^ self solvePrimitive: method primitive receiver: receiver arguments: arguments]
			on: DASTPrimitiveFailed
			do: [
				" Remove pragma node from method body to prevent infinit loop and continue with the excecution of the method body" 
				newContext := newContext removePrimitiveFromMethod;yourself ]
		].
	" Set new context "
	currentContext := newContext.
	currentContext setTemporalVariablesNamed: method argumentNames values: arguments.
	
]

{ #category : #visiting }
DASTInterpreter >> visitMethodNode: aRBBlockNode [ 
	
	
	
	
]

{ #category : #visiting }
DASTInterpreter >> visitReturnNode: aRBReturneNode [
	| value senderContext |
	
	value := currentContext stack top.
	senderContext := currentContext returnContext. 
	
	currentContext := senderContext.
	self stackPush: value
]

{ #category : #visiting }
DASTInterpreter >> visitSelfNode: aRBSelfNode [ 
	self stackPush: self currentContext receiver

]

{ #category : #visiting }
DASTInterpreter >> visitSequenceNode: aRBSequenceNode [ 
	
	| lastResult |
	lastResult := self currentContext isBlockContext 
		ifTrue: [ self stackPop ]
		ifFalse: [ self currentContext receiver ].
	
	currentContext := currentContext sender.
	self stackPush: lastResult. 
	
]

{ #category : #visiting }
DASTInterpreter >> visitSuperNode: aRBSuperNode [ 
	self stackPush: self currentContext receiver.
]

{ #category : #visiting }
DASTInterpreter >> visitTemporaryNode: aRBTemporaryNode [
	| name |
	name := aRBTemporaryNode name.
	aRBTemporaryNode isDefinition 
		ifTrue: [ currentContext at: name put: nil ]
		ifFalse: [ self stackPush: (currentContext findVariable: name)]
]

{ #category : #visiting }
DASTInterpreter >> visitThisContextNode: aRBThisContextNode [ 
	self stackPush: currentContext
]

{ #category : #visiting }
DASTInterpreter >> visitVariableNode: aRBVariableNode [ 

	aRBVariableNode isDefinition
		ifTrue: [ currentContext at: aRBVariableNode name put: nil ].
	self stackPush: (currentContext findVariable: aRBVariableNode name)
]

{ #category : #visiting }
DASTInterpreter >> write: value toInstVarNamed: name [

	self currentContext receiver instVarNamed: name put: value
]
