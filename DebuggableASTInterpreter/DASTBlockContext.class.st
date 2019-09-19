"
I am a context created to evaluate the body of a block
"
Class {
	#name : #DASTBlockContext,
	#superclass : #DASTContext,
	#category : #'DebuggableASTInterpreter-Contexts'
}

{ #category : #'accessing - private' }
DASTBlockContext >> allInstVars [ 
	^ closure outerContext allInstVars ,
	  sender allInstVars
]

{ #category : #'accessing - private' }
DASTBlockContext >> allTemps [
	^ self variablesDict associations ,
	  closure outerContext allTemps , 
	  sender allTemps 
]

{ #category : #initialization }
DASTBlockContext >> contextTag [
	^ closure outerContext
]

{ #category : #'API-lookup' }
DASTBlockContext >> findLocalVariable: aName [
	^ variablesDict 
		associationAt: aName 
		ifAbsent: [ 
			(closure outerContext findLocalVariable: aName) ifNil: [ 
				(self sender findLocalVariable: aName) ifNil: [ ^ nil ]
			]
		].
		
]

{ #category : #initialization }
DASTBlockContext >> initializeContext [
	
	| visitor |
	" My receiver is the DASTBlock that received the message value (or any of its variants)"
	self	parent: receiver outerContext.
	"
	aClass := (self receiver isNil and: [ aSelector = #value ]) 
		ifTrue: [ BlockClosure ]
		ifFalse: [ self getClassForLookup ].
	"
	visitor := DASTPostOrderTreeVisitor new.
	receiver body acceptVisitor: visitor.
	nodes := visitor stack.
	currentNode := nodes top.
	self 	methodOrBlock: receiver;
			nodes: nodes.
	
]

{ #category : #initialization }
DASTBlockContext >> isBlockContext [
	^ true
]

{ #category : #initialization }
DASTBlockContext >> isUnwindContext [
	"is this context for  method that is marked?"
	^ false
]

{ #category : #initialization }
DASTBlockContext >> method [
	^ closure outerContext method
]

{ #category : #initialization }
DASTBlockContext >> printOn: aStream [
	aStream nextPutAll: closure printString , ' in '.
			closure outerContext printOn: aStream
]

{ #category : #initialization }
DASTBlockContext >> receiver [
	^ closure outerContext receiver
]
