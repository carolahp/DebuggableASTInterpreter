Class {
	#name : #DASTBlock,
	#superclass : #DASTClosure,
	#instVars : [
		'interval'
	],
	#category : #'DebuggableASTInterpreter-Closures'
}

{ #category : #'accessing method dictionary' }
DASTBlock class >> lookupSelector: selector [
	" Hack for accessing method definition of BlockClosure while not inheriting from it"
	| method |
	method := super lookupSelector: selector.
	method ifNotNil: [ ^ method ].
	
	^ BlockClosure lookupSelector: selector
	
	
]

{ #category : #accessing }
DASTBlock >> basicClass [
	^ self class
]

{ #category : #'source code' }
DASTBlock >> bodyOffset [
	^ self outerContext methodOrBlock bodyOffset
]

{ #category : #accessing }
DASTBlock >> ensure: aBlock [
	"Evaluate a termination block after evaluating the receiver, regardless of
	 whether the receiver's evaluation completes.  N.B.  This method is *not*
	 implemented as a primitive.  Primitive 198 always fails.  The VM uses prim
	 198 in a context's method as the mark for an ensure:/ifCurtailed: activation."

	| complete returnValue |
	<primitive: 198>
	returnValue := self value "self valueNoContextSwitch".
	complete ifNil:[
		complete := true.
		aBlock value.
	].
	^ returnValue
]

{ #category : #'gt-extension' }
DASTBlock >> gtInspectorIn: composite [
	<gtInspectorPresentationOrder: 5>

	^composite text
		title: 'Source Code';
		display: [ self asString ];
		initialize: [ :presentation | 
			presentation selectionInterval: interval ];
		when: [ true ]
]

{ #category : #'gt-extension' }
DASTBlock >> gtInspectorIn: aGLMCompositePresentation highlightInterval: aCollection [ 
	^ self outerContext methodOrBlock gtInspectorIn: aGLMCompositePresentation highlightInterval: aCollection 

]

{ #category : #accessing }
DASTBlock >> initializeInterval [
	| parent methodClass intervalOffset |
	parent := self outerContext methodOrBlock.
	methodClass := '(', parent methodClass asString , ')>>'.
	intervalOffset := methodClass size.
	interval := (self nodeAST sourceInterval) collect: [:each | each + intervalOffset ].
]

{ #category : #accessing }
DASTBlock >> initializeWith: aRBNode [
	self assert: aRBNode isBlock.
	(aRBNode body statements isEmpty) ifTrue: [ aRBNode body addNode: (RBLiteralValueNode value: nil) ].
	super initializeWith:  aRBNode.
	
	
]

{ #category : #accessing }
DASTBlock >> interval [
	^ interval
]

{ #category : #accessing }
DASTBlock >> isBlock [ 
	^true
]

{ #category : #accessing }
DASTBlock >> isMessageValue [
	^ false
]

{ #category : #accessing }
DASTBlock >> isPrimitive [ 
	"A block always has code inside, and cannot have a primitive declaration "
	^ false
]

{ #category : #accessing }
DASTBlock >> methodClass [
	^ self outerContext methodOrBlock methodClass
]

{ #category : #accessing }
DASTBlock >> outerContext [
	^ outerContext 
]

{ #category : #accessing }
DASTBlock >> outerContext: aDASTContext [
	outerContext := aDASTContext.
	self initializeInterval
]

{ #category : #accessing }
DASTBlock >> primitive [ 
	"A block always has code inside, and cannot have a primitive declaration "
	^ 0
]

{ #category : #'gt-extension' }
DASTBlock >> printOn: aStream [
	aStream nextPutAll: self nodeAST source asString
	
]

{ #category : #accessing }
DASTBlock >> selector [
	 
	^ 'value' "nodeAST sourceCode"
]

{ #category : #'gt-extension' }
DASTBlock >> sourceCodeInMethod [
	^ self nodeAST source asString
	
]

{ #category : #'source code' }
DASTBlock >> sourceCodeWithClassAndSelector [
	^ self outerContext methodOrBlock sourceCodeWithClassAndSelector
]

{ #category : #accessing }
DASTBlock >> value1: anArg [
	| block |
	block := Smalltalk compiler
		source: self sourceCode;
		context: self outerContext;
		receiver: self outerContext receiver;
		evaluate.
	^ block value: anArg
]
