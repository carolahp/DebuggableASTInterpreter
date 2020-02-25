"
I can interpret a program represented as an AST
"
Class {
	#name : #DASTInterpreter,
	#superclass : #Object,
	#instVars : [
		'currentContext',
		'programCounter',
		'evaluator',
		'astCache',
		'myComposite'
	],
	#category : #'DebuggableASTInterpreter-Core'
}

{ #category : #accessing }
DASTInterpreter >> astCache: aCollection [ 
	astCache := aCollection
]

{ #category : #accessing }
DASTInterpreter >> context [
	self shouldBeImplemented.
]

{ #category : #accessing }
DASTInterpreter >> contextsStack [
	^ {self currentContext} asOrderedCollection , self currentContext senders
]

{ #category : #accessing }
DASTInterpreter >> currentContext [
	^ currentContext.
]

{ #category : #accessing }
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
		node := currentContext nodes top.
		self stepInto.
		"self stepOver."
		"myComposite ifNotNil: [myComposite update]."
		 ].
	^ self stackTop
]

{ #category : #evaluation }
DASTInterpreter >> evaluateAST: aRBNode [ 
	^ self evaluateAST: aRBNode withTemps: #() 
]

{ #category : #evaluation }
DASTInterpreter >> evaluateAST: aRBNode withTemps: aCollection [ 

	self initializeWithProgram: aRBNode withTemps: aCollection astCache: astCache.
	^ self evaluate.
]

{ #category : #accessing }
DASTInterpreter >> evaluator [
	^ evaluator ifNil: [ evaluator := DASTSystemEnvironment new interpreter: self; yourself ]
]

{ #category : #'gt-extension' }
DASTInterpreter >> gtInspectorContextsIn: composite [
	<gtInspectorPresentationOrder: 1>
	self currentContext ifNil: [ ^ composite ].
	^composite fastList
		title: 'Evaluation Stack';
		display: [ {self currentContext} asOrderedCollection , self currentContext senders ]
]

{ #category : #'gt-extension' }
DASTInterpreter >> gtInspectorCurrentContextIn: composite [
	<gtInspectorPresentationOrder: 0>
	myComposite := composite.
	^(self currentContext) 
		ifNil: [ composite ] 
		ifNotNil: [ :ctx | ctx gtInspectorSourceIn: composite]
]

{ #category : #'gt-extension' }
DASTInterpreter >> gtInspectorVariablesIn: composite [
	<gtInspectorPresentationOrder: 3>
	self currentContext ifNil: [ ^ composite ].
	^ self currentContext gtInspectorVarsIn: composite
]

{ #category : #evaluation }
DASTInterpreter >> increasePC [
	programCounter := self programCounter + 1
]

{ #category : #initialization }
DASTInterpreter >> initializeWithContext: aDASTContext [
	"initialize the interpreter to resume the execution from the context got as argument"

	| visitor nodes rootContext  aRBNode aCollection|
self halt.
	astCache := IdentityDictionary new. 
	programCounter := 0.
	visitor := DASTPostOrderTreeVisitor new.
	
	(aRBNode methodNode body addReturn; yourself) acceptVisitor: visitor.
	nodes := visitor stack.
	rootContext := DASTContextRootSmalltalk new 
		evaluator: self evaluator;
		yourself.
	"ugly method necessary because we are putting the root expression of the AST inside a return and sending it the message value"
	self flag: 'update next call'.
	" Set the first method (noMethod) context evaluation. The receiver is nil "
	currentContext := DASTMethodContext new
		receiver: self evaluator nilObject;
		parent: rootContext;
		methodOrBlock: (DASTMethod new initializeWith: nodes last methodNode evaluator: self evaluator);
		nodes: nodes;
		sender: rootContext;
		temps: aCollection;
		evaluator: self evaluator;
		yourself.
	
]

{ #category : #initialization }
DASTInterpreter >> initializeWithEvaluator: anEPASTEvaluator [ 
	evaluator := anEPASTEvaluator
]

{ #category : #initialization }
DASTInterpreter >> initializeWithProgram: aRBNode [
	^self initializeWithProgram: aRBNode withTemps: #() astCache: astCache
	
]

{ #category : #initialization }
DASTInterpreter >> initializeWithProgram: aRBNode inContext: aDASTContext [ 
	| visitor nodes rootContext  aCollection |
	astCache := aDASTContext evaluator astCache. 
	self flag: 'how can I handle program counter?'.
	programCounter := 0 .
	nodes := self flattenedNodesFrom: aRBNode.
	
	" Set the first method (noMethod) context evaluation. The receiver is nil "
	currentContext := aDASTContext nodes: nodes; 
		stack: DASTStack new;  
		methodOrBlock: aDASTContext methodOrBlock;
		yourself
]

{ #category : #initialization }
DASTInterpreter >> initializeWithProgram: aRBNode withTemps: aCollection astCache: anIdentityDictionary [
	
	astCache := anIdentityDictionary. 
	programCounter := 0.
	currentContext := DASTContext newNoMethodContextWithProgram: aRBNode temps: aCollection evaluator: self evaluator

]

{ #category : #testing }
DASTInterpreter >> isTerminated [
	self flag: 'ToDo: is this method necessary?'.
	^ self currentContext nodes isEmpty and: [self currentContext parent isRoot].
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

{ #category : #evaluation }
DASTInterpreter >> restart: aDASTContext [
	| newContext temps nargs |
	newContext := 
		DASTContext
			newWithSender: aDASTContext sender 
			receiver: aDASTContext receiver 
			messageNode: aDASTContext messageNode
			evaluator: aDASTContext evaluator.
	nargs := aDASTContext messageNode arguments.
	temps := aDASTContext allTemps reverse.
	nargs doWithIndex: [ :arg :i | | temp |
		temp := temps at: i.
		newContext at: temp name put: temp value
	].
	
	currentContext := newContext
]

{ #category : #private }
DASTInterpreter >> solvePrimitive: aMethod receiver: anObject arguments: anArray [
	| primitiveResult anInteger |
	anInteger := aMethod primitive.
	
	"primitives applied to blocks:"
	(anObject isKindOf: DASTClosure) ifTrue: [ 
		anInteger = 266 ifTrue: [
			self halt. 
			^self stackPush: anObject argumentCount. 
		 ].
		anInteger = 202 ifTrue: [ 
			self halt.
			primitiveResult := anObject tryPrimitive: anInteger withArgs: anArray asArray.
			^ self stackPush: primitiveResult
		].
		DASTPrimitiveFailed signalWithPrimitive: anInteger receiver: anObject 
	].
	"apply primitive to object"
	primitiveResult := self evaluator executePrimitiveMethod: aMethod withReceiver: anObject withArguments: anArray asArray.
	(self evaluator primitiveResultIsError: primitiveResult)
		ifTrue: [ DASTPrimitiveFailed signalWithPrimitive: anInteger receiver: anObject ].
	self stackPush: (self evaluator valueOf: primitiveResult)
	
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
	node := currentContext nodes pop.
	currentContext currentNode: node.
	self visit: node.
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
		and: currentContext senders size > initialContext senders size 
		"and: [ currentContext ~= initialContext sender ]" ]
		whileTrue: [ self stepInto ].
	^ self currentContext
]

{ #category : #evaluation }
DASTInterpreter >> stepThrough [
	| initialContext |
	initialContext := currentContext.
	self stepInto.
	[ (currentContext = initialContext or: currentContext senders size <= initialContext senders size)
		or: ((currentContext parent = initialContext) and: currentContext isBlockContext) ]
	whileFalse: [ self stepInto ]. 
	
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
	| literals size arrayMirror |
	size := aRBArrayNode statements size.
	literals := self stackPop: size.
	arrayMirror := self evaluator newArrayWithAll: literals reverse.
	self stackPush: arrayMirror
]

{ #category : #visiting }
DASTInterpreter >> visitAssignmentNode: aRBAssignmentNode [ 
	| name value |
	name := aRBAssignmentNode variable name.
	value := self stackTop.
	self currentContext assignVariable: name value: value
]

{ #category : #visiting }
DASTInterpreter >> visitBlockNode: aRBBlockNode [ 
	| block blockMirror |
	block := DASTBlock new initializeWith: aRBBlockNode; outerContext: currentContext.
	
	blockMirror := self evaluator blockFrom: block.
	
	self stackPush: blockMirror 
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
	self stackPush: (self readInstanceVariableNamed: aRBInstanceVariableNode name)
]

{ #category : #visiting }
DASTInterpreter >> visitLiteralArrayNode: aRBLiteralArrayNode [ 
	
	| literals size |
	size := aRBLiteralArrayNode contents size.
	literals := self stackPop: size.
	self stackPush: (self evaluator newArrayWithAll: literals)
]

{ #category : #visiting }
DASTInterpreter >> visitLiteralNode: aRBLiteralValueNode [ 
	self stackPush: (self evaluator literalFrom: aRBLiteralValueNode value)

]

{ #category : #visiting }
DASTInterpreter >> visitLiteralValueNode: aRBLiteralValueNode [ 
	self visitLiteralNode: aRBLiteralValueNode
]

{ #category : #visiting }
DASTInterpreter >> visitMessageNode: aRBMessageNode [ 
	| arguments receiver method newContext |
	" Resolve Arguments "

	"self haltIf: [ aRBMessageNode selector = #methodDict ]."
	arguments := (self stackPop: aRBMessageNode numArgs) reverse.	
	(aRBMessageNode isCascaded and: [aRBMessageNode isFirstCascaded not]) ifTrue: [ self stackPop ].
	receiver := self stackPop.
	
	" Current context initialization (implicit lookup)"
	newContext := 
		DASTContext
			newWithSender: self currentContext 
			receiver: receiver 
			messageNode: aRBMessageNode
			evaluator: self evaluator.
	
	" Lookup"
	method := newContext methodOrBlock.
	" Apply - invoke method "
	(aRBMessageNode isCascaded and: [aRBMessageNode parent messages last ~= aRBMessageNode]) ifTrue: [ self stackPush: receiver ]. 
	(method isPrimitive and: [method isMessageValue not and: [method isOnDo not]] )  
	ifTrue: [ 
		[ ^ self solvePrimitive: method receiver: receiver arguments: arguments ]
		on: DASTPrimitiveFailed 
		do: [ 
			" Remove pragma node from method body to prevent infinit loop 
			  and continue with the excecution of the method body"
			  newContext := newContext removePrimitiveFromMethod;yourself.
			]
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
		ifTrue: [ currentContext at: name put: self evaluator nilObject ]
		ifFalse: [ self stackPush: (currentContext findVariable: name)]
]

{ #category : #visiting }
DASTInterpreter >> visitThisContextNode: aRBThisContextNode [ 
	self stackPush: currentContext
]

{ #category : #visiting }
DASTInterpreter >> visitVariableNode: aRBVariableNode [ 

	aRBVariableNode isDefinition
		ifTrue: [ currentContext at: aRBVariableNode name put: evaluator nilObject ].
		
	self stackPush: (currentContext findVariable: aRBVariableNode name)
]

{ #category : #visiting }
DASTInterpreter >> write: value toInstVarNamed: name [
	self currentContext write: value toInstVarNamed: name
]
